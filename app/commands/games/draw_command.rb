module Games
  class DrawCommand < PlayerCommand
    attr_reader :number

    def initialize(params = {})
      @number = params[:number]
      super(params)
    end

    def call
      puts "TODO: implement this (draw card)"

      @post_action = [ Games::DrawCommand, { player_id: player.id, number: number + 1 } ]

      self
    end
  end
end
