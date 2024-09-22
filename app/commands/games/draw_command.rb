module Games
  class DrawCommand < PlayerCommand
    attr_reader :number

    def initialize(params = {})
      @number = params[:number]
      super(params)
    end

    def call
      current_player_index = game.game_data["current_player_index"]
      game.game_data["players"][current_player_index]["hand"] << game.game_data["supply_pile"].pop
      game.save

      self
    end
  end
end
