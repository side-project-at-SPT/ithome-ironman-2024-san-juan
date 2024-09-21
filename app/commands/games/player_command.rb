module Games
  class PlayerCommand
    include ActiveModel::Validations

    attr_reader :game, :player

    # 1. 遊戲是否存在
    # 2. 玩家是否存在
    # 3. 是否輪到玩家
    # 4. 遊戲是否正在進行
    validate :game_exists?, :player_exists?, :player_turn?, :status_playing?

    def initialize(params = {})
      @game = Game.find(params[:game_id])
      @player = User.new(params[:player_id])
      validate!
    end

    private

    def game_exists?
      errors.add(:game, "not found") unless game.present?
    end

    def player_exists?
      errors.add(:player, "not found") unless player.present?
    end

    def player_turn?
      errors.add(:player, "not your turn") unless game&.current_player_id == player&.id
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
