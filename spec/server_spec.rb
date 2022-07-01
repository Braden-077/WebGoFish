require 'rack/test'
require 'rspec'
require 'capybara'
require 'capybara/dsl'
require 'pry'
require 'webdrivers'
require 'card'
ENV['RACK_ENV'] = 'test'
require_relative '../server'
 
RSpec.describe Server do
  let(:session1) { Capybara::Session.new(:selenium_chrome_headless, Server.new) }
  let(:session2) { Capybara::Session.new(:selenium_chrome_headless, Server.new) }
  let(:session3) { Capybara::Session.new(:selenium_chrome_headless, Server.new) }
  let(:all_sessions) { [session1, session2, session3]}
  let(:normal_sessions) { [session1, session2]}
  # include Rack::Test::Methods
  include Capybara::DSL
  before do
    Capybara.app = Server.new
  end

  after do
    all_sessions.each {|session| session.driver.quit}
    Server.close
  end

  it 'is possible to join a game' do
    visit '/'
    fill_in :name, with: 'John'
    click_on 'Join'
    expect(page).to have_content('Players')
    expect(page).to have_content('You')
  end

  it 'allows multiple players to join game' do
    session_setup(normal_sessions)
    expect(session1).to have_content('Players')
    expect(session2).to have_content('Players')
    expect(session1).to have_css('b', text: 'You')
    expect(session2).to have_css('b', text: 'You')
    expect(session2).to have_content('Player 1')
    expect(session1).to have_content('Player 2')
  end

  it 'shows that it\'s waiting on players when only one player is connected' do
  session_setup([session1])
  expect(session1).to have_content('Waiting on players...')
  
  end

  it 'starts the game when two players have joined' do
    session_setup(normal_sessions)
    expect(session1).to have_css('select', class: 'form__dropdown')
    expect(session1).to have_no_content(Server.game.players.last.hand)
    expect(session2).to have_no_css('select', class: 'form__dropdown')
    expect(session2).to have_no_content(Server.game.players.first.hand)
    expect(session1).to have_content('It\'s your turn')
    expect(session2).to have_content('It\'s Player 1\'s turn')
  end

  describe 'taking a turn' do
    it 'takes a card when the player has it' do
      session_setup(normal_sessions)
      rig_game([Card.new('Ace', 'S'), Card.new('Ace', 'C')], [Card.new('Ace', 'D')], [], normal_sessions)
    
      session1.select 'Ace', from: 'rank'
      session1.select 'Player 2', from: 'player-name'
      session1.click_on 'Ask'

      expect(session2).to have_no_css('select', class: 'form__dropdown')
      expect(session1).to have_content('It\'s your turn')
    end

    it 'ends the turn if the player does not have it' do
      session_setup(normal_sessions)
      rig_game([Card.new('Ace', 'S'), Card.new('Ace', 'C')], [Card.new('2', 'D')], [Card.new('3', 'D')], normal_sessions)

      session1.select 'Ace', from: 'rank'
      session1.select 'Player 2', from: 'player-name'
      session1.click_on 'Ask'
  
      expect(session1).to have_no_content('It\'s your turn')
      expect(session1).to have_content("You asked Player 2 for Ace's. Go fish!")
      expect(session1).to have_content('It\'s Player 2\'s turn')
      expect(session2).to have_content("Player 1 asked You for Ace's. Go fish!")
      expect(session2).to have_content('It\'s your turn')
    end

    it 'continues turn if fishing is successful' do
      session_setup(normal_sessions)
      rig_game([Card.new('Ace', 'S'), Card.new('Ace', 'C')], [Card.new('2', 'D')], [Card.new('Ace', 'D')], normal_sessions)

      session1.select 'Ace', from: 'rank'
      session1.select 'Player 2', from: 'player-name'
      session1.click_on 'Ask'

      expect(session1).to have_content('It\'s your turn')
      expect(session1).to have_no_content('It\'s Player 2\'s turn')
      expect(session2).to have_no_content('It\'s your turn')
    end

    it 'gives the current player a card if their hand is empty' do
      session_setup(normal_sessions)
      rig_game([Card.new('Ace', 'S'), Card.new('Ace', 'C')], [], [Card.new('3', 'D'), Card.new('4', 'D')], normal_sessions)

      session1.select 'Ace', from: 'rank'
      session1.select 'Player 2', from: 'player-name'
      session1.click_on 'Ask'

      expect(session2).to have_content('It\'s your turn')

      session2.select '4', from: 'rank'
      session2.select 'Player 1', from: 'player-name'
      session2.click_on 'Ask'
    end

    it 'sends the players to the game over screen when the game ends' do
      session_setup(normal_sessions)
      rig_game([Card.new('Ace', 'S'), Card.new('Ace', 'C')], [Card.new('Ace', 'H'), Card.new('Ace', 'D')], [], normal_sessions, book1: ['2', '3', '4', '5', '6', '7', '8', '9'], book2: ['10', 'Jack', 'Queen', 'King'])

      session1.select 'Ace', from: 'rank'
      session1.select 'Player 2', from: 'player-name'
      session1.click_on 'Ask'

      expect(session1).to have_content('Game Over')
      expect(session1.current_path).to eq '/game_over'
      expect(session2).to have_content('Game Over')
      expect(session2.current_path).to eq '/game_over'
      normal_sessions.each {|session| expect(session).to have_button('Play again') }
      session1.click_on 'Play again'
      expect(session1.current_path).to eq '/'
    end

    it 'redirects extra players instead of allowing them to join the game' do
      session_setup([session1, session2, session3])

      expect(session3.current_path).to eq '/denied_access'
    end

    fit 'allows you to add a bot to the game' do
      session1.visit '/'
      expect(session1).to have_button 'Play against a bot'
      session1.fill_in :name, with: 'Braden'
      session1.click_on 'Play against a bot'
      expect(session1.current_path).to eq '/game'
    end
  end

  def session_setup(sessions)
    sessions.each_with_index do |session, index|
      player_name = "Player #{index + 1}"
      session.visit '/'
      session.fill_in :name, with: player_name
      session.click_on 'Join'
    end

    def rig_game(hand1, hand2, deck, sessions, book1: [], book2: [])
      Server.game.players[0].hand = hand1
      Server.game.players[0].books = book1
      Server.game.players[1].hand = hand2
      Server.game.players[1].books = book2
      Server.game.deck.cards = deck
      sessions.each {|session| session.driver.refresh}
    end
  end
end