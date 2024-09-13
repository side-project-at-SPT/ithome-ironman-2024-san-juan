class Cards::BlankCard < Cards::BaseCard
  class << self
    def id
      "00"
    end
  end

  def name
    "Blank Card"
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
    -1
  end
end
