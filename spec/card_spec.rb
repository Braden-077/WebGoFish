# frozen_string_literal: true

require 'card'

describe Card do
  describe 'valid initialization' do
    it 'allows for valid ranks and suits' do
      card = Card.new('A', 'S')
      expect(card.rank).to eq 'A'
      expect(card.suit).to eq 'S'
    end

    it 'tests the ranks if they are the same' do
      card1 = Card.new('A', 'S')
      card2 = Card.new('A', 'C')
      expect(card1).to be_same_rank(card2.rank)
    end
  end

  describe 'invalid initialization' do
    it 'does not allow for incorrect suits and ranks' do
      card = Card.new('Test', 'Test')
      expect(card.rank).to be_nil
      expect(card.suit).to be_nil
    end
  end
end