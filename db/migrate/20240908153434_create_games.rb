class CreateGames < ActiveRecord::Migration[7.2]
  def change
    create_table :games do |t|
      t.integer :status, null: false, default: 0 # 0: unknown, 1: playing, 2: finished

      t.timestamps
    end
  end
end
