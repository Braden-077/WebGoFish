require_relative 'deck'

class Game
  attr_accessor :players, :deck, :round_count, :started_status
  def initialize(players = [], deck = Deck.new)
    @players = players
    @deck = deck
    @started_status = false
    @round_count = 1
  end

  def add_player(player)
    players.push(player)
  end

  def empty?
    players.empty?
  end

  def start
    deck.shuffle! 
    determined_card_num.times {players.each {|player| player.take_cards(deck.deal)}}
    @started_status = true
  end

  def determined_card_num
    if players.length >= 4
      5
    elsif players.length <= 3
      7
    end
  end

  def turn_player
    turn = (@round_count - 1) % players.count 
    players[turn]
  end

  def up_round
    @round_count += 1
  end

  def ready_to_start?
    return if started_status
    players.count >= 2
  end 
end