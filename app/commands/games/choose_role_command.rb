module Games
  class ChooseRoleCommand < PlayerCommand
    attr_reader :role

    def initialize(params = {})
      super(params)
      @role = validate_role!(params[:role])
    end

    def call
      # puts "ChooseRoleCommand call"
      # puts "game current user index: #{game.game_data["current_player_index"]}"
      # puts game.game_data["players"][0]
      # puts game.game_data["players"][game.current_player_id]
      # puts
      role.in? game.game_data["roles"]

      # update game data
      # game_data = game.game_data
      # pp role
      # game_data["roles"].delete(role)
      # pp game_data["roles"]
      # pp game.game_data["roles"].delete(role)
      game.game_data["roles"].delete(role)
      # puts "-----------------" + "set player role" + "-----------------"
      game.game_data["players"][game.game_data["current_player_index"]]["role"] = role
      game.save

      # puts "-----------------" + "game data" + "-----------------"
      # game.reload
      # pp game.players
      # pp game.game_data["players"]

      # pp game.game_data["roles"]
    end

    class InvalidRoleError < RuntimeError
      def initialize(invalid_role = nil)
        @invalid_role = invalid_role
      end

      def message
        "Invalid Role: #{@invalid_role}"
      end
    end

    private

    def validate_role!(params_role = nil)
      raise InvalidRoleError.new(params_role) unless (role = find_role(params_role))

      role
    end

    def find_role(value)
      return nil unless value

      case value.to_s.downcase
      when "1", "建築師", "builder"
        Roles::Builder.to_s
      when "2", "製造商", "producer"
        Roles::Producer.to_s
      when "3", "貿易商", "trader"
        Roles::Trader.to_s
      when "4", "礦工", "prospector"
        Roles::Prospector.to_s
      when "5", "議員", "councillor"
        Roles::Councillor.to_s
      else
        nil
      end
    end
  end
end
