module Games
  class StartNewRoundCommand
    include ActiveModel::Validations

    attr_reader :game, :player, :post_action, :description, :message

    def initialize(params = {})
      # @message = params[:message] || "Unimplemented command called"
      @game = params.delete(:game)
    end

    def call
      puts "=== === === 開始新的一輪 === === ==="

      # reset the roles
      game.game_data[:roles] = Roles::All
      players = game.players
      players.each { |player| player.role = nil }
      game.game_data["players"] = players
      game.save

      # for testing purpose, we remove the role prospector
      game.game_data["roles"].delete("Games::Roles::Prospector")
      game.save

      @post_action = [ Games::NotifyNextTurnBeginsCommand, {
        description: "換下一位玩家",
        current_player: game.players[game.game_data["current_player_index"]]
      } ]

      self
    end
  end
end
