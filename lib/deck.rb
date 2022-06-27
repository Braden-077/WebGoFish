# frozen_string_literal: true 

require_relative 'card'

class Deck
  attr_accessor :cards
  def initialize(cards = build_deck)
    @cards = cards
  end

  def cards_left
    cards.length
  end

  def deal
    cards.shift
  end

  def shuffle!
    cards.shuffle!
  end

  private

  def build_deck
    Card::SUITS.flat_map do |suit|
      Card::RANKS.map do |rank|
        card = Card.new(rank, suit)
      end
    end
  end
end