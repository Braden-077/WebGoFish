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
      player = Player.new('Braden', [Card.new('Ace', 'H')], ['Ace', 'Jack'])
      expect(player.name).to eq 'Braden'
      expect(player.hand).to eq [Card.new('Ace', 'H')]
      expect(player.books).to eq ['Ace', 'Jack']
    end
  end

  describe '#take_cards' do
    it 'takes the card(s) passed in' do 
      player = Player.new('Braden', [Card.new('Ace', 'H')])
      player.take_cards(Card.new('Ace', 'S'))
      expect(player.hand).to eq [Card.new('Ace', 'H'), Card.new('Ace', 'S')]
    end
  end

  describe '#give_cards' do
    it 'gives the cards matching the rank' do 
      player = Player.new('Braden', [Card.new('Ace', 'H'), Card.new('Ace', 'S'), Card.new('2', 'S')])
      cards = player.give_cards('Ace')
      expect(cards).to eq  [Card.new('Ace', 'H'), Card.new('Ace', 'S')]
      expect(player.hand).to eq [Card.new('2', 'S')]
    end
  end
  
  describe '#check_for_books' do
    it 'checks for books and deletes the correct cards' do
      player = Player.new('Braden', [Card.new('Ace', 'H'), Card.new('2', 'S'), Card.new('Ace', 'D')])
      player.check_for_books
      expect(player.books.count).to be 0
      player.take_cards([Card.new('Ace', 'C'), Card.new('Ace', 'S')])
      player.check_for_books
      expect(player.hand).to eq [Card.new('2', 'S')]
      expect(player.books.count).to eq 1
    end
  end

  describe '#sort_hand!' do
    it 'sorts the hand' do 
      player = Player.new('Braden', [Card.new('Queen', 'S'), nil, nil, nil, Card.new('2', 'H'), nil, Card.new('7', 'D'), Card.new('8', 'C'), nil])
      player.sort_hand!
      expect(player.hand).to eq [Card.new('2', 'H'), Card.new('7', 'D'), Card.new('8', 'C'), Card.new('Queen', 'S')]
    end
  end

  describe '#has_rank?' do
    it 'checks for the card in a player\'s hand' do 
      player = Player.new('Braden', [Card.new('Ace', 'H'), Card.new('Ace', 'S'), Card.new('Ace', 'D'), Card.new('2', 'S')])
      expect(player.has_rank?('Ace')).to be true
      expect(player.has_rank?('2')).to be true
      expect(player.has_rank?('4')).to be false
    end
  end

  describe '#show_unique_cards' do
    it 'only shows one card for two\'s and three\'s' do
      player = Player.new('Josh', [Card.new('2', 'S'), Card.new('2', 'C'), Card.new('3', 'D'), Card.new('3', 'H')])
      expect(player.show_unique_cards).to match_array ['2', '3']
    end
  end

  describe '#format' do
    it 'should replace their name in a string with you' do
      player1 = Player.new('Josh')
      player2 = Player.new('Braden')
      result = 'Josh took A\'s from Braden.' 
      expect(player1.format(result)).to eq 'You took A\'s from Braden.'
      expect(player2.format(result)).to eq 'Josh took A\'s from You.'
    end
  end
end