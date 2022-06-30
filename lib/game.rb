require_relative 'deck'

class Game
  attr_accessor :players, :deck, :round_count, :started_status, :round_results
  TOTAL_BOOKS = 13
  MAX_PLAYERS = 2
  def initialize(players = [], deck = Deck.new)
    @players = players
    @deck = deck
    @started_status = false
    @round_count = 1
    @round_results = []
  end

  def add_player(player)
    return if players.count >= MAX_PLAYERS
    players.push(player)
    round_results.push('A new challenger approaches!')
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
    current_player = turn_player
    if player.has_rank?(rank)
      current_player.take_cards(player.give_cards(rank))
      successful_take_message(current_player, rank, player)
    elsif !player.has_rank?(rank)
      failure_to_take_message(current_player, rank, player)
      send_fishing(current_player, rank)
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

  def check_emptiness
    return unless turn_player.hand.empty?
    if turn_player.hand.empty? && deck.cards.empty?
      round_results.push("#{turn_player.name}'s hand is empty and the deck is empty! Next!")
      up_round
    elsif turn_player.hand_empty?
      round_results.push("#{turn_player.name} ran out of cards! Have one from the deck, on me!")
      turn_player.take_cards(deck.deal)
    end
  end

  def history # tested in play_round
    if round_results.length > players.count
      round_results.shift until round_results.length <= (players.count + 2)
    end
    round_results
  end

  def winner
    book_counts = players.map {|player| player.books.count}
    players.reject {|people| people.books.count != book_counts.max }.first
  end

  private # all of these are helper methods called during play_round

  def successful_take_message(turn_player, rank, asked_player)
    round_results.push("#{turn_player.name} took #{rank}'s from #{asked_player.name}!")
  end

  def failure_to_take_message(turn_player, rank, asked_player)
    round_results.push("#{turn_player.name} asked #{asked_player.name} for #{rank}'s. Go fish!")
  end

  def successful_fishing_message(turn_player, rank)
    round_results.push("#{turn_player.name} went fishing and succeeded in fishing a #{rank}!")
  end

  def failure_fishing_message(turn_player)
   round_results.push("#{turn_player.name} went fish and failed!")
  end
   
  def send_fishing(current_player, rank)
    if go_fish == rank
      successful_fishing_message(current_player, rank)
    else
      up_round
      failure_fishing_message(current_player)
    end
  end
end