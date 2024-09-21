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
end
