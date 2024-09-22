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
      game.turn_over!

      self
    end
  end
end
