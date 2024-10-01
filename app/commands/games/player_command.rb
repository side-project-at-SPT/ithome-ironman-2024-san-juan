module Games
  class PlayerCommand
    include ActiveModel::Validations

    attr_reader :game, :player, :post_action, :description

    # 1. 遊戲是否存在
    # 2. 玩家是否存在
    # 3. 是否輪到玩家
    # 4. 遊戲是否正在進行
    validate :game_exists?, :player_exists?, :player_turn?, :status_playing?

    def initialize(params = {})
      @game = params.delete(:game)
      @player = User.new(params.delete(:player_id), game&.id)
      @description = params.delete(:description)
      validate

      Rails.logger.debug { "PlayerCommand: #{self.class.name}, description: #{description}" }
      Rails.logger.debug { "params:" }
      Rails.logger.debug { params.merge(game: game.then { |g| [ g.id, g.status, g.updated_at ] }, player: player.id) }
    end

    # 執行 post action if exists
    def resolve_post_action(game:, options: {})
      # 1. extract @post_action to build a new command
      # 2. call the new command
      # 3. loop until there is no post action
      # 4. a hard limit of 99 post actions to prevent infinite loop
      executions = 0
      executions_limit = 50
      while post_action.present? && executions < executions_limit
        # pp post_action
        command_klass, command_params = post_action
        if options[:np] == false && command_klass == Games::NotifyNextTurnBeginsCommand
          break
        end
        @post_action = command_klass.new(command_params.merge(game: game)).call.post_action
        executions += 1
      end

      if executions >= executions_limit
        raise "Too many post actions, executed #{executions} times, possible infinite loop"
      end

      self
    end

    private

    def game_exists?
      errors.add(:game, "not found") unless game.present?
    end

    def player_exists?
      errors.add(:player, "not found") unless player.present?
    end

    def player_turn?
      # TODO: implement this
      # errors.add(:player, "not your turn") unless game&.current_player_id == player&.id

      # NOTE: for now, we just assign the player to the current player
      @player = User.new(game&.current_player_id, game&.id)
    end

    def status_playing?
      errors.add(:status, "is not playing") unless game&.status_playing?
    end
  end

  class User
    attr_reader :id, :game_id

    def initialize(id, game_id = nil)
      @id = id
      @game_id = game_id
    end

    # @return [Array<Integer>] player's hand
    def hand
      Game.find(game_id).players.filter { |p| p["id"] == id }.first["hand"]
    end
  end
end
