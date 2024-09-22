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
      @player = User.new(params.delete(:player_id))
      @description = params.delete(:description)
      validate

      Rails.logger.debug { "PlayerCommand: #{self.class.name}, description: #{description}" }
      Rails.logger.debug { "params:" }
      Rails.logger.debug { params.merge(game: game.then { |g| [ g.id, g.status, g.updated_at ] }, player: player.id) }
    end

    # 執行 post action if exists
    def resolve_post_action(game:)
      # 1. extract @post_action to build a new command
      # 2. call the new command
      # 3. loop until there is no post action
      # 4. a hard limit of 10 post actions to prevent infinite loop
      executions = 0
      while post_action.present? && executions < 10
        command_klass, command_params = post_action
        @post_action = command_klass.new(command_params.merge(game: game)).call.post_action
        executions += 1
      end
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
      @player = User.new(game&.current_player_id)
    end

    def status_playing?
      errors.add(:status, "is not playing") unless game&.status_playing?
    end
  end

  class User
    attr_reader :id

    def initialize(id)
      @id = id
    end
  end
end
