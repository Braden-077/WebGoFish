# frozen_string_literal: true

require 'deck' 

describe Deck do
  describe '#initialize' do
    it 'initializes a deck with 52 cards' do
      deck = Deck.new
      expect(deck.cards_left).to eq 52
    end

    it 'allows for the user to build a deck using one card, should they want to' do
      deck = Deck.new([Card.new('A', 'S')])
      expect(deck.cards_left).to eq 1
    end
  end

  describe '#deal' do
    it 'allows the deck to deal one card (and get the correct output)' do
      deck = Deck.new
      expect(deck.deal).to eq Card.new('2', 'C')
      expect(deck.cards_left).to eq 51
    end
  end

  describe '#shuffle' do
    it 'allows the deck to be shuffled' do
      deck1 = Deck.new
      deck2 = Deck.new
      expect(deck1.shuffle!).not_to eq(deck2.cards)
      expect(deck1.shuffle!).to match_array deck2.cards
    end
  end
end