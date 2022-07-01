require 'sinatra'
require 'pusher'
require 'sprockets'
require 'sass'
require_relative 'lib/game'
require_relative 'lib/player'

class Server < Sinatra::Base
  enable :sessions
  # Start Assets
  set :environment, Sprockets::Environment.new
  environment.append_path "assets/stylesheets"
  environment.append_path "assets/javascripts"
  environment.css_compressor = :scss
  get "/assets/*" do
    env["PATH_INFO"].sub!("/assets", "")
    settings.environment.call(env)
  end

  def pusher_client
    @pusher_client ||= Pusher::Client.new(
      app_id: "1430657",
      key: "f8902beee86dc0f3da1c",
      secret: "a691039411bca05e7415",
      cluster: "us2",
      useTLS: true
    )
  end

  get '/denied_access' do
    slim :denied_access
  end
  
  def self.game
    @@game ||= Game.new
  end
  
  def self.close
    @@game = nil 
  end

  get '/' do
    slim :index
  end

  get '/game_over' do
    redirect '/' unless self.class.game.over?
    slim :game_over, locals: { game: self.class.game}
  end

  post '/join' do
    player = Player.new(params['name'])
    session[:current_player] = player
    self.class.game.add_player(player)
    redirect '/denied_access' if self.class.game.players.none? {|person| person.name == params['name']}
    pusher_client.trigger('go-fish', 'game-changed', { message: "A new challenger approaches! Welcome, #{player.name}." })
    redirect '/game'
  end
  
  get '/game' do
    redirect '/' if self.class.game.empty?
    redirect '/game_over' if self.class.game.over?
    self.class.game.start if self.class.game.ready_to_start?
    player = self.class.game.find_player(session[:current_player].name)
    slim :game, locals: { game: self.class.game, current_player: player }
  end

  get '/styleguide' do
    slim :styleguide
  end

  post '/play_round' do
    self.class.game.play_round(params['rank'], params['player-name'])
    pusher_client.trigger('go-fish', 'game-changed', { message: "Turn taken." })
    pusher_client.trigger('go-fish', 'game-changed', { message: "Game state changed" })
    redirect '/game'
  end
end