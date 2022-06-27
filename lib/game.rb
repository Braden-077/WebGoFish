class Game
  attr_accessor :players
  def initialize(players = [])
    @players = players
  end

  def add_player(player)
    players.push(player)
  end

  def empty?
    players.empty?
  end
end