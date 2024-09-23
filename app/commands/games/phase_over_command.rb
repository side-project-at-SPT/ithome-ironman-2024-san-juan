module Games
  class PhaseOverCommand
    include ActiveModel::Validations

    attr_reader :game, :player, :post_action, :description, :message

    def initialize(params = {})
      # @message = params[:message] || "Unimplemented command called"
      @game = params.delete(:game)
    end

    def call
      puts "=== #{game.phase} is over ==="
      # when phase is over,
      # 1. check if end_game condition is met
      # 2. if not, check if all players choose the role
      # 3. if yes, current round is over, start a new round
      # 4. if not, start a new phase

      if end_game_condition_met?
        puts "TODO: implement this (call game over)"
        raise "game over"
      end

      # the current player is the last player of current phase
      # the next player is the first player of the current phase
      # so the next phase's first player is 2 steps ahead of the current player
      game.game_data[:current_player_index] = (game.game_data["current_player_index"] + 2) % 4
      game.phase = :choose_role
      game.save


      if all_players_choose_role?
        # since the current player is the first player of the current round
        # the new round's first player is the next player
        game.game_data[:current_player_index] = (game.game_data["current_player_index"] + 1) % 4
        game.save
        @post_action = [ StartNewRoundCommand, {
          description: "開始新的一輪"
        } ]
      else
        # game.notify_next_turn
        @post_action = [ NotifyNextTurnBeginsCommand, {
          description: "換下一位玩家",
          current_player: game.players[game.game_data["current_player_index"]]
        } ]
      end

      self
    end

    private

    # 檢查是否滿足遊戲結束條件
    def end_game_condition_met?
      # if anyone has 12 buildings, the game is over
      game.players.any? { |player| player.buildings.size >= 12 }
    end

    # 檢查是否所有玩家都選擇了職業
    def all_players_choose_role?
      # puts "-" * 10 + "檢查是否所有玩家都選擇了職業" + "-" * 10
      # pp game.players.map(&:role)
      game.players.all? { |player| player.role.present? }
    end
  end
end
