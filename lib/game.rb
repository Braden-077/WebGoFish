require_relative 'deck'

class Game
  attr_accessor :players, :deck, :round_count, :started_status
  TOTAL_BOOKS = 13
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

  def go_fish
    return up_round if deck.cards.empty?
    card = turn_player.take_cards(deck.deal)
    card.rank
  end

  def play_round(rank, player_name)
    player = find_player(player_name)
    if player.has_rank?(rank)
      turn_player.take_cards(player.give_cards(rank))
    elsif !player.has_rank?(rank)
      up_round unless go_fish == rank
    end
  end

  def over?
    players.sum {|player| player.books.length} == TOTAL_BOOKS
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

  def find_player(name)
    players.find {|player| player.name == name}
  end

  def return_opponent_names 
    players.reject {|player| player == turn_player}.map {|player| player.name}
  end
end