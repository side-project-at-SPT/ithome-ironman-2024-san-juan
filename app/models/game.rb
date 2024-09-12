class Game < ApplicationRecord
  enum :status, {
    unknown: 0,
    playing: 1,
    finished: 2
  }, prefix: true

  def play
    return errors.add(:status, "can't be blank") unless status_playing?

    self.status_finished!
  end

  class << self
    def start_new_game
      game = new(status: :playing)
      # 1. generate a random seed
      game.seed = SecureRandom.hex(16)

      # 2. shuffle the 5 trading house tiles
      game.game_data[:trading_house_order] = TradingHouse.new(seed: game.seed).order

      # 3. deal indigo plant to players as initial building
      # 4. shuffle remaining cards to form a deck
      # 5. deal 4 cards to each player as their initial hand, hidden from other players
      # 6. choose first player
      game.save

      game
    end
  end

  def current_price
    TradingHouse.new(game_data["trading_house_order"]).current_price
  end
end
