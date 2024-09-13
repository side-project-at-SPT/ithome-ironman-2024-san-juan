class Cards::BaseCard
  # 卡片的屬性有：
  # - 名稱
  # - 價格
  # - 類型：工廠 | 城市建築
  # - 分數
  # - 張數
  # - id (產生卡片物件時用)

  # declare DECK_SIZE to fill the deck with blank cards
  DECK_SIZE = 110.freeze

  @@card_class = {}

  class << self
    def card_class
      @@card_class
    end

    def <<(klass)
      @@card_class[klass.id] = klass
    end

    def id
      raise NotImplementedError
    end
  end

  def name
    raise NotImplementedError
  end

  def price
    raise NotImplementedError
  end

  def type
    raise NotImplementedError
  end

  def score
    raise NotImplementedError
  end

  def amount
    raise NotImplementedError
  end

  def id
    self.class.id
  end

  def to_h
    {
      id: id,
      name: name,
      price: price,
      type: type,
      score: score,
      amount: amount
    }
  end
end

class String
  def to_card
    if self.in? Cards::BaseCard.card_class.keys
      Cards::BaseCard.card_class[self].new
    else
      raise "#{self} is not a valid card id"
    end
  end
end

Cards::BaseCard << Cards::BlankCard
Cards::BaseCard << Cards::IndigoPlant
# Cards::BaseCard.card_class["02"] = Cards::SugarMill
# Cards::BaseCard.card_class["03"] = Cards::TobaccoStorage
# Cards::BaseCard.card_class["04"] = Cards::CoffeeRoaster
# Cards::BaseCard.card_class["05"] = Cards::SilverSmelter
# Cards::BaseCard.card_class["06"] = Cards::Smithy
# Cards::BaseCard.card_class["07"] = Cards::GoldMine
# Cards::BaseCard.card_class["08"] = Cards::Archive
# Cards::BaseCard.card_class["09"] = Cards::PoorHouse
# Cards::BaseCard.card_class["10"] = Cards::BlackMarket
# Cards::BaseCard.card_class["11"] = Cards::TradingPost
# Cards::BaseCard.card_class["12"] = Cards::Well
# Cards::BaseCard.card_class["13"] = Cards::MarketStand
# Cards::BaseCard.card_class["14"] = Cards::Crane
# Cards::BaseCard.card_class["15"] = Cards::Chapel
# Cards::BaseCard.card_class["16"] = Cards::Tower
# Cards::BaseCard.card_class["17"] = Cards::Aqueduct
# Cards::BaseCard.card_class["18"] = Cards::Carpenter
# Cards::BaseCard.card_class["19"] = Cards::Prefecture
# Cards::BaseCard.card_class["20"] = Cards::MarketHall
# Cards::BaseCard.card_class["21"] = Cards::Quarry
# Cards::BaseCard.card_class["22"] = Cards::Library
# Cards::BaseCard.card_class["23"] = Cards::Statue
# Cards::BaseCard.card_class["24"] = Cards::VictoryColumn
# Cards::BaseCard.card_class["25"] = Cards::Hero
# Cards::BaseCard.card_class["26"] = Cards::GuildHall
# Cards::BaseCard.card_class["27"] = Cards::CityHall
# Cards::BaseCard.card_class["28"] = Cards::TriumphalArch
# Cards::BaseCard.card_class["29"] = Cards::Palace
# # Expansion: "The New Buildings"
# Cards::BaseCard.card_class["30"] = Cards::GuardRoom
# Cards::BaseCard.card_class["31"] = Cards::OfficeBuilding
# Cards::BaseCard.card_class["32"] = Cards::Hut
# Cards::BaseCard.card_class["33"] = Cards::Tavern
# Cards::BaseCard.card_class["34"] = Cards::Park
# Cards::BaseCard.card_class["35"] = Cards::CustomsOffice
# Cards::BaseCard.card_class["36"] = Cards::Bank
# Cards::BaseCard.card_class["37"] = Cards::Harbor
# Cards::BaseCard.card_class["38"] = Cards::Goldsmith
# Cards::BaseCard.card_class["39"] = Cards::Residence
# Cards::BaseCard.card_class["40"] = Cards::Cathedral
