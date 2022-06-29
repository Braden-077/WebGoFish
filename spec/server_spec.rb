require 'rack/test'
require 'rspec'
require 'capybara'
require 'capybara/dsl'
require 'pry'
ENV['RACK_ENV'] = 'test'
require_relative '../server'
 
RSpec.describe Server do
  let(:session1) { Capybara::Session.new(:rack_test, Server.new) }
  let(:session2) { Capybara::Session.new(:rack_test, Server.new) }
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
    [ session1, session2 ].each_with_index do |session, index|
      player_name = "Player #{index + 1}"
      session.visit '/'
      session.fill_in :name, with: player_name
      session.click_on 'Join'
      expect(session).to have_content('Players')
      expect(session).to have_css('b', text: player_name)
    end
    expect(session2).to have_content('Player 1')
    session1.driver.refresh
    expect(session1).to have_content('Player 2')
  end

  it 'shows that it\'s waiting on players when only one player is connected' do
    [ session1 ].each_with_index do |session, index|
      player_name = "Player #{index + 1}"
      session.visit '/'
      session.fill_in :name, with: player_name
      session.click_on 'Join'
      expect(session).to have_content('Waiting on players...')
    end
  end

  it 'starts the game when two players have joined' do
    [ session1, session2 ].each_with_index do |session, index|
      player_name = "Player #{index + 1}"
      session.visit '/'
      session.fill_in :name, with: player_name
      session.click_on 'Join'
    end
    session1.driver.refresh
    expect(session1).to have_css('input', class: 'form__radio')
    expect(session1).to have_no_content(Server.game.players.last.hand)
    expect(session2).to have_css('input', class: 'form__radio')
    expect(session2).to have_no_content(Server.game.players.first.hand)
    expect(session1).to have_content('It\'s your turn')
    expect(session2).to have_content('It\'s Player 1\'s turn')
  end

  it 'allows a turn to be taken' do
    [ session1, session2 ].each_with_index do |session, index|
      player_name = "Player #{index + 1}"
      session.visit '/'
      session.fill_in :name, with: player_name
      session.click_on 'Join'
    end
    session1.driver.refresh
    expect(session1).to have_css('button', class: 'btn--primary', count: 1)
    # session1.save_and_open_page
    session1.choose 'rank-radio-1'
    session1.choose 'name-radio-1'
    session1.click_on 'Ask'
    # expect(Server.game.players.first.hand_count).to 
    # select card, player, then ask
    # expect player1's hand to not be the basic 7 cards 
    # expect round result to have posted something new 
  end
end