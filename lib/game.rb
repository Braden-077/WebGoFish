require_relative 'deck'

class Game
  attr_accessor :players, :deck
  def initialize(players = [], deck = Deck.new)
    @players = players
    @deck = deck
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
  end

  def determined_card_num
    if players.length >= 4
      5
    elsif players.length <= 3
      7
    end
  end
end