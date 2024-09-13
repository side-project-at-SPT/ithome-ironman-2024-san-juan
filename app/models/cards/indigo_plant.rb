class Cards::IndigoPlant < Cards::BaseCard
  class << self
    def id
      "01"
    end
  end

  def name
    "Indigo Plant"
  end

  def price
    1
  end

  def type
    "Production"
  end

  def score
    1
  end

  def amount
    10
  end
end
