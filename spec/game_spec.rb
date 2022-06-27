require 'game'
require 'pry'

describe Game do
  describe '#add_player' do
    it 'adds player objects to an array' do
      game = Game.new
      expect { game }.not_to raise_error
      game.add_player(Player.new('Braden'))
      expect(game.players.count).to eq 1
      expect(game.players.first.name).to eq 'Braden'
    end
  end

  describe '#empty?' do
    it 'returns a boolean based on players being empty or not' do
      game = Game.new
      expect(game.empty?).to be true
      game.add_player('Josh')
      expect(game.empty?).to be false
    end
  end
end
