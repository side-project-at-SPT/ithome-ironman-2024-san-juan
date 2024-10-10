module Games
  # 所有共同的行為都放在這裡
  # Any common Constants, Methods, or Modules should be placed here

  module Roles
    class Builder; end
    class Producer; end
    class Trader; end
    class Prospector; end
    class Councillor; end

    All = [ Builder, Producer, Trader, Prospector, Councillor ].map(&:to_s).freeze
  end

  # module RoleValidation
  #   def builder? = role.in? [ Roles::BUILDER, "建築師", 1 ]
  #   def producer? = role.in? [ Roles::PRODUCER, "製造商", 2 ]
  #   def trader? = role.in? [ Roles::TRADER, "貿易商", 3 ]
  #   def prospector? = role.in? [ Roles::PROSPECTOR, "礦工", 4 ]
  #   def councillor? = role.in? [ Roles::COUNCILLOR, "議員", 5 ]
  # end

  class User
    attr_reader :id, :game_id

    def initialize(id, game_id = nil)
      @id = id
      @game_id = game_id
    end

    # @return [Array<Integer>] player's hand
    def hand
      Game.find(game_id).players.filter { |p| p["id"] == id }.first["hand"]
    end

    def draw_cards
      Game.find(game_id).players.filter { |p| p["id"] == id }.first["draw_cards"]
    end
  end
end
