# frozen_string_literal: true 

class Card
  SUITS = ['C', 'H', 'D', 'S']
  RANKS = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']

  attr_reader :rank, :suit
  def initialize(rank, suit)
    if RANKS.include?(rank) && SUITS.include?(suit)
      @suit = suit
      @rank = rank
    end
  end

  def ==(other)
    @rank == other.rank && @suit == other.suit
  end

  def <=>(other)
    return 0 unless other
    RANKS.index(@rank) <=> RANKS.index(other.rank)
  end

  def same_rank?(other)
    @rank == other
  end

  def to_s
    "#{rank} of #{suit}"
  end
end