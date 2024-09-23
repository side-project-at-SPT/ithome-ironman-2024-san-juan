class GameStep < ApplicationRecord
  belongs_to :game

  enum :reason, {
    unknown: 0,
    game_init: 1,
    choose_role: 2,
    builder_action: 3,
    producer_action: 4,
    trader_action: 5,
    prospector_action: 6,
    councillor_action: 7,
    game_over: 8,
    round_begin: 9,
    round_end: 10,
    phase_begin: 11,
    phase_end: 12,
    player_turn_begin: 13,
    player_turn_end: 14
  }, prefix: true
end
