module Games
  class CouncillorKeepCommand < PlayerCommand
    attr_reader :card_id

    def initialize(params = {})
      @card_id = params[:card_id]
      super(params)
    end

    def call
      privilege_description = "None"

      # 檔案室 議員階段可以從手牌棄牌
      has_archive = false

      # 總督府 議員階段多保留 1 張卡片
      has_prefecture = false

      if Rails.env.test?
        puts "[test]   CouncillorKeepCommand called\tdescription: #{description}"
      end

      # TODO: implement this <<

      if has_archive
        # check if the card_id is in the player's hand or in the draw cards
        unless player.hand.include?(card_id) || player.draw_cards.include?(card_id)
          raise "The card_id is not in the player's hand or in the draw cards"
        end
      else
        # check if the card_id is in the player's hand
        unless player.hand.include?(card_id)
          raise "The card_id is not in the player's hand"
        end
      end




      number = 2 + 3 * (has_library ? 2 : 1)
      DrawCommand.new(game: game, player: player, number: number, description: "玩家 #{player.id} 抽了 #{number} 張卡片").call

      after_draw_hands = player.hand
      drew_cards = after_draw_hands.dup[before_draw_hand_count, number]

      Rails.logger.debug { "before_draw_hands: #{before_draw_hands}" }
      Rails.logger.debug { "after_draw_hands: #{after_draw_hands}" }
      Rails.logger.debug { "drew_cards: #{drew_cards}" }

      game.generate_game_steps(
        reason: "councillor_action",
        description: "玩家 #{player.id} 抽了 #{number} 張卡片"
      )
      # @post_action = [ Games::CouncillorKeepCommand, { description: "玩家 #{player.id} 選擇保留一張卡片" } ]
      # KeepCommand

      # @post_action = [ Games::TurnOverCommand, { description: "礦工抽卡結束，換下一位玩家" } ]

      self
    end
  end
end
