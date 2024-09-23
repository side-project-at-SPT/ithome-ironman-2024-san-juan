module Games
  class UnimplementedCommand < PlayerCommand
    attr_reader :message

    def initialize(params = {})
      @message = params[:message] || "Unimplemented command called"
      super(params)
    end

    def call
      pp message

      game.turn_over!

      self
    end
  end
end
