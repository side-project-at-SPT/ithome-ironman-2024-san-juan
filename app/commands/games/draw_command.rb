module Games
  class DrawCommand < PlayerCommand
    attr_reader :number

    def initialize(params = {})
      @number = params[:number]
      super(params)
    end

    def call
      puts "Draw Command called"
      current_player_index = game.game_data["current_player_index"]
      draw = 0
      while draw < number
        # TODO: implement this
        raise "Not enough cards in the supply pile" if game.game_data["supply_pile"].empty?

        game.game_data["players"][current_player_index]["hand"] << game.game_data["supply_pile"].pop
        draw += 1
      end
      game.save

      self
    end
  end
end
