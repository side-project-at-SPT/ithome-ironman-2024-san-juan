module Games
  class ProspectorDrawCommand < PlayerCommand
    attr_reader :number

    def initialize(params = {})
      @number = params[:number]
      super(params)
    end

    def call
      puts "Prospector Draw Command called"
      DrawCommand.new(game: game, player: player, number: number).call

      # current player's turn over, time to move to the next player
      # game.turn_over!
      @post_action = [ Games::TurnOverCommand, { description: "礦工抽卡結束，換下一位玩家" } ]

      self
    end
  end
end
