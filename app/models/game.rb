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
    def generate_seed = SecureRandom.hex(16)

    def start_new_game(seed: nil)
      game = new(status: :playing)
      # 1. generate a random seed
      game.seed = seed || SecureRandom.hex(16)

      # 2. shuffle the 5 trading house tiles
      game.game_data[:trading_house_order] = TradingHouse.new(seed: game.seed).order

      # 3. remove 1 indigo plant from the deck for each player
      #    shuffle the remaining cards, forming a supply pile
      # 3.1. generate the deck
      deck = generate_deck

      # 3.2. remove 1 indigo plant from the deck for each player
      deck.shift(game.players.size)

      # 3.3. shuffle the remaining cards to form a supply pile
      deck.shuffle!
      game.game_data[:supply_pile] = deck

      # 4. deal 4 cards to each player as their initial hand, hidden from other players
      # 5. choose first player
      game.save

      game
    end

    private

    def generate_deck
      # 3.1. initialize the deck
      # 3.1.1. determine how many cards in the deck
      deck_size = Cards::BaseCard::DECK_SIZE

      # 3.1.2. generate a deck in order
      deck = Cards::BaseCard.card_class.keys.map do |id|
        next if id == Cards::BlankCard.id

        Cards::BaseCard.card_class[id].new.amount.times.map { id }
      end
      deck = deck.flatten.compact

      # 3.1.3. fill the deck with blank cards if deck size is not enough
      blank_card_id = Cards::BlankCard.id
      deck += (deck_size - deck.size).times.map { blank_card_id }
    end
  end

  def current_price
    TradingHouse.new(game_data["trading_house_order"]).current_price
  end

  # FIXME: hardcode 4 players for now
  def players
    Struct.new(:size).new(
      size: 4
    )
  end
end
