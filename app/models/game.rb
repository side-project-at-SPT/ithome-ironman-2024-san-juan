class Game < ApplicationRecord
  enum :status, {
    unknown: 0,
    playing: 1,
    finished: 2
  }, prefix: true

  enum :phase, {
    unknown: 0,
    choose_role: 1,
    builder: 2,
    producer: 3,
    trader: 4,
    prospector: 5,
    councillor: 6,
    game_over: 7
  }, suffix: true

  has_many :game_steps

  def generate_game_steps(reason: 0, description: "")
    steps = game_steps.last&.steps || -1
    game_steps.create(game_data: game_data, steps: steps + 1, reason: reason, description: description)
  end

  Building = Struct.new(:id, :good_id, :card_ids)
  Player = Struct.new(:id, :hand, :buildings, :role, :is_bot) do
    def to_json
      {
        id: id,
        is_bot: is_bot,
        hand: hand,
        role: role,
        buildings: buildings
      }
    end
  end

  def restart
    status_playing!
    save
    self.class.start_new_game(seed: seed, game: self)
  end

  def build_assign_role_command(**params)
    command_builder(Games::ChooseRoleCommand, params.merge(description: "選擇職業"))
  end

  # @param role_class_name [String] role class name
  def start_phase!(role_class_name)
    # 1. start a new phase
    self.phase = role_class_name.demodulize.downcase.to_sym

    # 2. set up waiting players(start from the current player) for the phase, with that we can track who has finished their turn
    self.game_data[:waiting_players] = [ 0, 1, 2, 3 ].rotate(game_data["current_player_index"])
    self.save

    puts "\nPhase: #{phase} started"
    puts "  #{game_data["waiting_players"][0]}'s turn begins"
  end

  class << self
    def generate_seed = SecureRandom.hex(16)

    def start_new_game(seed: nil, game: nil)
      game ||= new(status: :playing, phase: :choose_role)

      # 1. generate a random seed
      game.seed = seed || SecureRandom.hex(16)
      game.save

      # 1.1. generate players and choose the first player
      game.game_data[:players] = generate_players(seed: game.seed)
      game.game_data[:current_player_index] = 0
      game.save

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

      # 4. Give each player 1 indigo plant as their initial building
      players = game.players

      players.each do |player|
        player.buildings += [ Building.new("01") ]
      end

      # 5. deal 4 cards to each player as their initial hand, hidden from other players
      players.each do |player|
        player.hand = deck.shift(4)
      end

      # 6. prepare role cards
      roles = Games::Roles::All

      # save the game data
      game.game_data[:players] = players
      game.game_data[:supply_pile] = deck
      game.game_data[:roles] = roles
      game.game_data[:rounds] = 1
      game.save

      game.generate_game_steps(reason: "game_init", description: "遊戲開始")

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

    # FIXME: hardcode 4 players for now
    def generate_players(seed: nil)
      srand(seed.to_i(16)) if seed

      human_player = Player.new(1, [], [], nil, false)
      bot_players = 3.times.map { |i| Player.new(i + 2, [], [], nil, true) }

      ([ human_player ] + bot_players).shuffle
    end
  end

  def current_price
    TradingHouse.new(game_data["trading_house_order"]).current_price
  end

  def players
    return [] unless game_data["players"]

    game_data["players"].map do |player|
      Player.new(player["id"], player["hand"], player["buildings"].map { |building|
        Building.new(building["id"], building["good_id"], building["card_ids"])
      }, player["role"], player["is_bot"])
    end
  end

  def current_player_id
    return nil unless game_data["players"]

    players[game_data["current_player_index"]]["id"]
  end

  def rounds
    game_data["rounds"]
  end

  private

  # 產生任意 command
  # @param command [Class] command class
  # @param params [Hash] command parameters
  # @return [Games::PlayerCommand] command instance
  def command_builder(command, params)
    command.new(params.merge(game: self))
  end

  # 檢查玩家是否為 bot
  def player_is_bot?(player)
    player.is_bot
  end
end
