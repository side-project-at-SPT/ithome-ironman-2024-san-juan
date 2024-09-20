class Cards::TobaccoStorage < Cards::BaseCard
  class << self
    def id
      "00"
    end
  end

  def name
    "Blank Card"
  end

  def ch_name
    "空白卡"
  end

  def description
    "This is a blank card."
  end

  def price
    1
  end

  def type
    "city"
  end

  def score
    1
  end

  def amount
    -1
  end
end
