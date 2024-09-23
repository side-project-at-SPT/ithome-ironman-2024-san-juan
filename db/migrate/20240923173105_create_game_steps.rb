class CreateGameSteps < ActiveRecord::Migration[7.2]
  def change
    create_table :game_steps do |t|
      t.belongs_to :game, null: false, foreign_key: true
      t.json :game_data, null: false, default: {}
      t.string :description
      t.integer :steps, null: false
      t.integer :reason, null: false, default: 0
      # 0: unknown, 1: game_init, 2: choose_role, 3: builder_action, 4: producer_action,
      # 5: trader_action, 6: prospector_action, 7: councillor_action, 8: game_over
      # 9: round_begin, 10: round_end,
      # 11: phase_begin, 12: phase_end
      # 13: player_turn_begin, 14: player_turn_end

      t.timestamps
      t.index [ :game_id, :steps ], unique: true
    end
  end
end
