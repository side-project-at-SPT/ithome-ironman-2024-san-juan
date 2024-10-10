module Games
  class NotifyNextTurnBeginsCommand
    include ActiveModel::Validations

    attr_reader :game, :current_player, :post_action, :description, :message

    def initialize(params = {})
      # @message = params[:message] || "Unimplemented command called"
      @game = params.delete(:game)
      @current_player = params.delete(:current_player)
      @description = params.delete(:description)
    end

    def call
      game.generate_game_steps(reason: "player_turn_begin", description: "輪到 #{current_player.id} 了")
      Rails.logger.debug { "TODO: notify next turn" }
      puts "\n  current phase: #{game.phase} \n\n"
      if game.choose_role_phase?
        puts "  目前玩家(#{current_player.is_bot ? 'bot' : 'human'})必須選擇職業"
      else
        puts "  目前玩家(#{current_player.is_bot ? 'bot' : 'human'})必須執行行動"
      end
      puts "  it's idx: #{game.game_data["current_player_index"]}'s turn"

      if game.choose_role_phase?
        if current_player.is_bot
          @post_action = [ Games::RandomlyChooseRoleCommand, {
            player_id: current_player.id,
            description: "隨機選擇職業"
          } ]
        else
          # raise "wait for human player to take action"
          #
          wait_for_human_player_to_take_action = false
          if wait_for_human_player_to_take_action
            # no-op
            nil
          else
            @post_action = [ Games::RandomlyChooseRoleCommand, {
              player_id: current_player.id,
              description: "隨機選擇職業"
            } ]
          end
        end
      else
        # no-op
        # puts "  目前階段: #{game.phase} 仍未實作"
        # @post_action = [ Games::TurnOverCommand, { description: "換下一位玩家" } ]
        if Rails.env.test?
          puts "[test]  " + "current phase: #{game.phase}"
          puts "[test]  " + "current player: #{current_player.id}"
          puts "[test]  目前階段: #{game.phase} 仍未實作"
        end
      end

      self
    end
  end
end
