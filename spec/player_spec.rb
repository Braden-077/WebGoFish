# frozen_string_literal: true 

require 'player'

describe Player do
  describe '#initalize' do
    it 'initializes a player with default paramaters' do
      player = Player.new
      expect { player }.not_to raise_error
      expect(player.name).to eq ''
      expect(player.hand).to be_empty
      expect(player.books).to be_empty
    end

    it 'initializes with given paramaters' do 
      player = Player.new('Braden', [Card.new('A', 'H')], ['A', 'J'])
      expect(player.name).to eq 'Braden'
      expect(player.hand).to eq [Card.new('A', 'H')]
      expect(player.books).to eq ['A', 'J']
    end
  end

  describe '#take_cards' do
    it 'takes the card(s) passed in' do 
      player = Player.new('Braden', [Card.new('A', 'H')])
      player.take_cards(Card.new('A', 'S'))
      expect(player.hand).to eq [Card.new('A', 'H'), Card.new('A', 'S')]
    end
  end

  describe '#give_cards' do
    it 'gives the cards matching the rank' do 
      player = Player.new('Braden', [Card.new('A', 'H'), Card.new('A', 'S'), Card.new('2', 'S')])
      cards = player.give_cards('A')
      expect(cards).to eq  [Card.new('A', 'H'), Card.new('A', 'S')]
      expect(player.hand).to eq [Card.new('2', 'S')]
    end
  end
  
  describe '#check_for_books' do
    it 'checks for books and deletes the correct cards' do
      player = Player.new('Braden', [Card.new('A', 'H'), Card.new('2', 'S'), Card.new('A', 'D')])
      player.check_for_books
      expect(player.books.count).to be 0
      player.take_cards([Card.new('A', 'C'), Card.new('A', 'S')])
      player.check_for_books
      expect(player.hand).to eq [Card.new('2', 'S')]
      expect(player.books.count).to eq 1
    end
  end

  describe '#sort_hand' do
    it 'sorts the hand' do 
      player = Player.new('Braden', [Card.new('Q', 'S'), nil, nil, nil, Card.new('2', 'H'), nil, Card.new('7', 'D'), Card.new('8', 'C'), nil])
      player.sort_hand
      expect(player.hand).to eq [Card.new('2', 'H'), Card.new('7', 'D'), Card.new('8', 'C'), Card.new('Q', 'S')]
    end
  end

  describe '#has_rank?' do
    it 'checks for the card in a player\'s hand' do 
      player = Player.new('Braden', [Card.new('A', 'H'), Card.new('A', 'S'), Card.new('A', 'D'), Card.new('2', 'S')])
      expect(player.has_rank?('A')).to be true
      expect(player.has_rank?('2')).to be true
      expect(player.has_rank?('4')).to be false
    end
  end
end