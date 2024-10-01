module Games
  class CouncillorPrivilegeCommand < PlayerCommand
    def initialize(params = {})
      super(params)
    end

    def call
      privilege_description = "多抽取 3 張卡片"

      # 圖書館 所有階段特權加倍
      has_library = false

      # 總督府 議員階段多保留 1 張卡片
      has_prefecture = false

      puts "Councillor Draw Command called"
      before_draw_hands = player.hand
      before_draw_hand_count = before_draw_hands.count

      number = 2 + 3 * (has_library ? 2 : 1)
      DrawCommand.new(game: game, player: player, number: number).call

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
