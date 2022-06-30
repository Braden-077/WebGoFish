# frozen_string_literal: true 

require 'pry'
class Player
  attr_accessor :name, :hand, :books
  def initialize(name = '', hand =  [], books = [])
    @name = name
    @hand = hand
    @books = books
  end

  def format(result)
    result.gsub(name, 'You')
  end

  def take_cards(cards)
    hand.push(cards).flatten!
    check_for_books
    sort_hand
    cards
  end

  def has_rank?(rank)
    hand.any? {|card| card.same_rank?(rank)}
  end

  def hand_count
    hand.count
  end

  def hand_empty?
    hand.empty?
  end

  def give_cards(rank)
    cards_to_give = hand.filter {|card| card.same_rank?(rank)}
    hand.delete_if {|card| cards_to_give.include?(card)}
    cards_to_give
  end

  def check_for_books
    hand.delete_if {|card| card.nil?}
    card_ranks = hand.map {|card| card.rank}
    Card::RANKS.each do |rank| 
      if card_ranks.count {|card_rank| rank == card_rank} == 4
        hand.delete_if {|card| card.rank == rank}
        books.push(rank)
      end
    end
  end

  def sort_hand
    hand.sort!.delete_if {|card| card.nil?}
  end

  def show_unique_cards
    hand.map {|card| card.rank}.uniq
  end
end