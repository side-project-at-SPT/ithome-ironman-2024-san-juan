module Games
  class TurnOverCommand
    include ActiveModel::Validations

    attr_reader :game, :player, :post_action, :description, :message

    def initialize(params = {})
      # @message = params[:message] || "Unimplemented command called"
      @game = params.delete(:game)
    end

    def call
      c_player = game.game_data["waiting_players"].shift

      if Rails.env.test?
        puts "[test]   #{c_player}'s turn is over"
      end

      game.save

      game.generate_game_steps(reason: "player_turn_end", description: "#{c_player} 的回合結束")

      # 1. check if the waiting player is blank?
      # 1.1. if blank, then the phase is over
      # 1.2. if not blank, then move to the next player
      if game.game_data["waiting_players"].blank?
        @post_action = [ Games::PhaseOverCommand, { description: "#{game.phase} is over" } ]
        return self
      else

        # 3. move to the next player
        game.game_data[:current_player_index] = game.game_data["waiting_players"].first
        game.save
      end

      @post_action = [ Games::NotifyNextTurnBeginsCommand, {
        description: "換下一位玩家",
        current_player: game.players[game.game_data["current_player_index"]]
      } ]

      self
    end
  end
end
