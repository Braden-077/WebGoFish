# frozen_string_literal: true 

require 'bot'

fdescribe BotPlayer do
  describe 'initialize' do
    
  end

  describe 'inherited' do
    describe '#take_cards' do
      it 'takes the card(s) passed in' do 
        bot = BotPlayer.new(name: 'Braden', hand: [Card.new('Ace', 'H')])
        bot.take_cards(Card.new('Ace', 'S'))
        expect(bot.hand).to eq [Card.new('Ace', 'H'), Card.new('Ace', 'S')]
      end
    end

    describe '#give_cards' do
      it 'gives the cards matching the rank' do 
        bot = BotPlayer.new(name: 'Braden', hand:[Card.new('Ace', 'H'), Card.new('Ace', 'S'), Card.new('2', 'S')])
        cards = bot.give_cards('Ace')
        expect(cards).to eq  [Card.new('Ace', 'H'), Card.new('Ace', 'S')]
        expect(bot.hand).to eq [Card.new('2', 'S')]
      end
    end
  
    describe '#check_for_books' do
      it 'checks for books and deletes the correct cards' do
        player = BotPlayer.new(name: 'Braden', hand: [Card.new('Ace', 'H'), Card.new('2', 'S'), Card.new('Ace', 'D')])
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
        player = BotPlayer.new(name: 'Braden', hand: [Card.new('Queen', 'S'), nil, nil, nil, Card.new('2', 'H'), nil, Card.new('7', 'D'), Card.new('8', 'C'), nil])
        player.sort_hand!
        expect(player.hand).to eq [Card.new('2', 'H'), Card.new('7', 'D'), Card.new('8', 'C'), Card.new('Queen', 'S')]
      end
    end

    describe '#has_rank?' do
      it 'checks for the card in a player\'s hand' do 
        player = BotPlayer.new(name: 'Braden', hand: [Card.new('Ace', 'H'), Card.new('Ace', 'S'), Card.new('Ace', 'D'), Card.new('2', 'S')])
        expect(player.has_rank?('Ace')).to be true
        expect(player.has_rank?('2')).to be true
        expect(player.has_rank?('4')).to be false
      end
    end

    describe '#show_unique_cards' do
      it 'only shows one card for two\'s and three\'s' do
        player = BotPlayer.new(name: 'Josh', hand: [Card.new('2', 'S'), Card.new('2', 'C'), Card.new('3', 'D'), Card.new('3', 'H')])
        expect(player.show_unique_cards).to match_array ['2', '3']
      end
    end

    describe '#format' do
      it 'should replace their name in a string with you' do
        player1 = BotPlayer.new(name: 'Josh')
        player2 = BotPlayer.new(name: 'Braden')
        result = 'Josh took A\'s from Braden.' 
        expect(player1.format(result)).to eq 'You took A\'s from Braden.'
        expect(player2.format(result)).to eq 'Josh took A\'s from You.'
      end
    end
  end
end