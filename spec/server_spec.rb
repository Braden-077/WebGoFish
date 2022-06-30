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
  # include Rack::Test::Methods
  include Capybara::DSL
  before do
    Capybara.app = Server.new
  end

  after do
    Server.close
  end

  it 'is possible to join a game' do
    visit '/'
    fill_in :name, with: 'John'
    click_on 'Join'
    expect(page).to have_content('Players')
    expect(page).to have_content('John')
  end

  it 'allows multiple players to join game' do
    session_setup([session1, session2])
    expect(session1).to have_content('Players')
    expect(session2).to have_content('Players')
    expect(session1).to have_css('b', text: 'Player 1')
    expect(session2).to have_css('b', text: 'Player 2')
    expect(session2).to have_content('Player 1')
    expect(session1).to have_content('Player 2')
  end

  it 'shows that it\'s waiting on players when only one player is connected' do
  session_setup([session1])
  expect(session1).to have_content('Waiting on players...')
  
  end

  it 'starts the game when two players have joined' do
    session_setup([session1, session2])
    expect(session1).to have_css('select', class: 'form__dropdown')
    expect(session1).to have_no_content(Server.game.players.last.hand)
    expect(session2).to have_no_css('select', class: 'form__dropdown')
    expect(session2).to have_no_content(Server.game.players.first.hand)
    expect(session1).to have_content('It\'s your turn')
    expect(session2).to have_content('It\'s Player 1\'s turn')
  end

  describe 'taking a turn' do
    it 'takes a card when the player has it' do
     session_setup([session1, session2])
     rig_game([Card.new('A', 'S'), Card.new('A', 'C')], [Card.new('A', 'D')], [], [session1, session2])

     session1.select 'A', from: 'rank'
     session1.select 'Player 2', from: 'player-name'
     session1.click_on 'Ask'

     expect(session2).to have_no_css('select', class: 'form__dropdown')
     expect(session1).to have_content('It\'s your turn')
    end

    it 'ends the turn if the player does not have it' do
      session_setup([session1, session2])
      rig_game([Card.new('A', 'S'), Card.new('A', 'C')], [Card.new('2', 'D')], [Card.new('3', 'D')], [session1, session2])

      
      session1.select 'A', from: 'rank'
      session1.select 'Player 2', from: 'player-name'
      session1.click_on 'Ask'
      


      expect(session1).to have_no_content('It\'s your turn')
      expect(session1).to have_content('It\'s Player 2\'s turn')
      expect(session2).to have_content('It\'s your turn')
    end

    it 'continues turn if fishing is successful' do
      session_setup([session1, session2])
      rig_game([Card.new('A', 'S'), Card.new('A', 'C')], [Card.new('2', 'D')], [Card.new('A', 'D')], [session1, session2])

      session1.select 'A', from: 'rank'
      session1.select 'Player 2', from: 'player-name'
      session1.click_on 'Ask'

      expect(session1).to have_content('It\'s your turn')
      expect(session1).to have_no_content('It\'s Player 2\'s turn')
      expect(session2).to have_no_content('It\'s your turn')
    end

    it 'gives the current player a card if their hand is empty' do
      session_setup([session1, session2])
      rig_game([Card.new('A', 'S'), Card.new('A', 'C')], [], [Card.new('3', 'D'), Card.new('4', 'D')], [session1, session2])

      session1.select 'A', from: 'rank'
      session1.select 'Player 2', from: 'player-name'
      session1.click_on 'Ask'

      expect(session2).to have_content('It\'s your turn')
      
      session2.select '4', from: 'rank'
      session2.select 'Player 1', from: 'player-name'
      session2.click_on 'Ask'
    end

    it 'sends the players to the game over screen when the game ends' do
      session_setup([session1, session2])
      rig_game([Card.new('A', 'S'), Card.new('A', 'C')], [Card.new('A', 'H'), Card.new('A', 'D')], [], [session1, session2], book1: ['2', '3', '4', '5', '6', '7', '8', '9'], book2: ['10', 'J', 'Q', 'K'])

      session1.select 'A', from: 'rank'
      session1.select 'Player 2', from: 'player-name'
      session1.click_on 'Ask'

      expect(session1).to have_content('Game is over.. I guess!')
      expect(session1.current_path).to eq '/game_over'
      expect(session2).to have_content('Game is over.. I guess!')
      expect(session2.current_path).to eq '/game_over'
    end

    it 'redirects extra players instead of allowing them to join the game' do
      session_setup([session1, session2, session3])

      expect(session3.current_path).to eq '/denied_access'
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