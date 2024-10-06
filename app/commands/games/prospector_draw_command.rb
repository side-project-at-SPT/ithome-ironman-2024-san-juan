module Games
  class ProspectorDrawCommand < PlayerCommand
    attr_reader :number

    def initialize(params = {})
      @number = params[:number]
      super(params)
    end

    def call
      if Rails.env.test?
        puts "[test]   Prospector Draw Command called"
      end

      DrawCommand.new(game: game, player: player, number: number).call
      game.generate_game_steps(
        reason: "prospector_action",
        description: "玩家 #{player.id} 抽了 #{number} 張卡片"
      )

      @post_action = [ Games::TurnOverCommand, { description: "礦工抽卡結束，換下一位玩家" } ]

      self
    end
  end
end
