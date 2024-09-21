module Games
  class PlayerCommand
    include ActiveModel::Validations

    attr_reader :game, :player, :post_action

    # 1. 遊戲是否存在
    # 2. 玩家是否存在
    # 3. 是否輪到玩家
    # 4. 遊戲是否正在進行
    validate :game_exists?, :player_exists?, :player_turn?, :status_playing?

    def initialize(params = {})
      @game = params[:game]
      @player = User.new(params[:player_id])
      validate!
    end

    def exec_post_action(params)
      game = Game.find(params[:game_id])
      @post_action = post_action[0].new(post_action[1].merge(game: game)).call
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
