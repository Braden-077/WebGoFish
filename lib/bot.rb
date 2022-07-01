require_relative 'player'

class BotPlayer < Player
  attr_accessor :name, :hand, :books, :difficulty
  NAMES = ['Roy', 'Jonathan', 'Logan', 'Rick Astley']
  def initialize(name: NAMES.sample, hand: [], books: [], difficulty: [])
    @name = name 
    @hand = hand
    @books = books
    @difficulty = difficulty
  end
end