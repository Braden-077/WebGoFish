require 'sinatra'
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
  
  def self.game
    @@game ||= Game.new
  end
  
  def self.close
    @@game = nil 
  end

  get '/' do
    slim :index
  end

  post '/join' do
    player = Player.new(params['name'])
    session[:current_player] = player
    self.class.game.add_player(player)
    redirect '/game'
  end

  get '/game' do
    redirect '/' if self.class.game.empty?
    self.class.game.start if self.class.game.ready_to_start?
    player = self.class.game.find_player(session[:current_player].name)
    slim :game, locals: { game: self.class.game, current_player: player }
  end

  get '/styleguide' do
    slim :styleguide
  end

  post '/play_round' do
    self.class.game.play_round(params['rank'], params['player-name'])
    redirect '/game'
  end
end