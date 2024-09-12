class TradingHouse
  # base prices for each trading house tile
  BASE_PRICES = [
    [ 1, 1, 1, 2, 2 ],
    [ 1, 1, 2, 2, 2 ],
    [ 1, 1, 2, 2, 3 ],
    [ 1, 2, 2, 2, 3 ],
    [ 1, 2, 2, 3, 3 ]
  ].each_with_object({}).with_index { |(prices, hash), index|
    hash[index] = prices
  }.freeze

  def draw_next_trading_house_tile
    el = @order.shift
    @order.push(el)
    self
  end

  # @param [Array<Integer>] trade card order
  # @param [String] seed hex string
  def initialize(params = nil, seed: nil)
    case params
    in nil
      raise ArgumentError, "seed must provided" unless seed

      # assume seed is hex
      srand(seed.to_i(16))
      @order = [ 0, 1, 2, 3, 4 ].shuffle
    in Array
      @order = params
    else
      raise ArgumentError, "order or seed must be provided"
    end
  end

  def order = @order

  def current_price = BASE_PRICES[@order.first]

  def indigo_price = current_price[0]
  def sugar_price = current_price[1]
  def tobacco_price = current_price[2]
  def coffee_price = current_price[3]
  def silver_price = current_price[4]

  def to_s
    <<~SHOW_PRICE
    Current Prices:
      Indigo:\t #{indigo_price}
      Sugar:\t #{sugar_price}
      Tobacco:\t #{tobacco_price}
      Coffee:\t #{coffee_price}
      Silver:\t #{silver_price}
    SHOW_PRICE
  end

  def inspect
    to_s
  end

  def next_five_round_price
    puts "next five round prices:"
    5.times do |i|
      puts(5.times.map { |j| BASE_PRICES[@order[i]][j] }.join(" "))
    end
    self
  end
end
