class AddPhaseToGames < ActiveRecord::Migration[7.2]
  def change
    add_column :games, :phase, :integer, null: false, default: 0 # 0: unknown, 1: choose_role, 2: builder, 3: producer, 4: trader, 5: prospector, 6: councillor, 7: game_over
  end
end
