module Games
  class ChooseRoleCommand < PlayerCommand
    attr_reader :role

    def initialize(params = {})
      super(params)
      @role = validate_role!(params[:role])
    end

    def call
      if errors.any?
        game.errors.add(:base, errors.full_messages.join(", "))
        return game
      end

      role_is_taken?(role, game.game_data["roles"]) do
        errors.add(:role, "#{role.demodulize} is being taken") and return self
      end

      game.game_data["roles"].delete(role)
      game.game_data["players"][game.game_data["current_player_index"]]["role"] = role
      game.save

      game.start_phase!(role)

      game.generate_game_steps(
        reason: "choose_role",
        description: "id:#{game.players[game.game_data["current_player_index"]].id} 選擇了 #{role.demodulize}"
      )

      # 判斷下一個動作要做什麼
      case game.phase
      when "prospector"
        # 判斷玩家是否有金礦或金工坊
        # 如果有，則讓玩家選擇要先執行哪個動作
        # 如果沒有，則直接執行礦工的動作
        player_buildings = game.game_data["players"][game.game_data["current_player_index"]]["buildings"]

        # if player_buildings.any? { |building| building["id"] == Cards::GoldMine.id || building["id"] == Cards::GoldSmithy.id }
        if player_buildings.any? { |building| building["id"] == "07" || building["id"] == "38" }
          # TODO: implement this
          puts "TODO: implement this (choose action)"
        else
          # 從牌庫抽取一張卡片
          @post_action = [
            Games::ProspectorDrawCommand,
            {
              player_id: player.id,
              number: 1,
              description: "選擇礦工玩家抽一張卡片"
            }
          ]
        end
      else
        @post_action = [ Games::TurnOverCommand, { description: "選擇職業結束，換下一位玩家" } ]
      end

      self
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

    def role_is_taken?(role, roles, &block)
      unless role.in? roles
        if block_given?
          block.call
        else
          raise InvalidRoleError.new(role)
        end
      end
    end

    def validate_role!(params_role = nil)
      if (role = find_role(params_role))
        role
      else
        errors.add(:role, "#{params_role} is invalid")
        nil
      end
    end

    def find_role(value)
      return nil unless value

      case value.to_s.demodulize.downcase
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
