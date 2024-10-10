module Games
  class CouncillorKeepCommand < PlayerCommand
    attr_reader :card_ids

    def initialize(params = {})
      @card_ids = params[:card_ids]
      super(params)
    end

    def call
      privilege_description = "None"

      # 檔案室 議員階段可以從手牌棄牌
      has_archive = false

      # 總督府 議員階段多保留 1 張卡片
      has_prefecture = false

      if Rails.env.test?
        puts "[test]   CouncillorKeepCommand called\t\tdescription: #{description}"
        puts "[test]" + " " * 42 + "keep_cards: #{card_ids.join(', ')}"
      end

      candidate_cards = []
      if has_archive
        candidate_cards = player.hand + player.draw_cards
      else
        candidate_cards = player.draw_cards
      end
      numbers_to_keep = 1 + (has_prefecture ? 1 : 0) + (has_archive ? player.hand.size : 0)

      if card_ids.size != numbers_to_keep
        raise "The number of card_ids is not equal to the numbers_to_keep"
      end

      # validate if the card_ids can be formed by the candidate_cards
      # which means each id of card_ids should be in the candidate_cards
      # and the count of each id should be less than or equal to the count of the id in the candidate_cards
      card_ids.tally.each do |card_id, count|
        if candidate_cards.count(card_id) < count
          raise "The card_ids(#{card_id}) is not in the candidate_cards or the count of card_ids is greater than the count of the card_id in the candidate_cards"
        end
      end

      current_player_index = game.game_data["current_player_index"]

      # pp _ = {
      #   current_player_index: current_player_index,
      #   player_hand: player.hand,
      #   game_data: game.game_data["players"]
      #   # player_hand_from_game: game.game_data["players"][current_player_index][:hand]
      # }

      if has_archive
        game.game_data["players"][current_player_index]["hand"] = card_ids
      else
        game.game_data["players"][current_player_index]["hand"] += card_ids
      end
      game.save

      if Rails.env.test?
        puts "[test]" + " " * 42 + "hand: #{player.hand.join(', ')}"
      end

      game.generate_game_steps(
        reason: "councillor_action",
        description: "玩家 #{player.id} 保留了卡片 (#{card_ids.join(', ')})"
      )

      @post_action = [ Games::TurnOverCommand, { description: "議員保留卡片結束，換下一位玩家" } ]

      self
    end
  end
end
