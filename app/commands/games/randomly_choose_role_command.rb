module Games
  class RandomlyChooseRoleCommand < ChooseRoleCommand
    def call
      # to clear role errors
      errors.clear
      @role = game.game_data["roles"].sample
      validate
      super
    end
  end
end
