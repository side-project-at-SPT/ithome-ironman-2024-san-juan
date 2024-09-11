class AddGameDetails < ActiveRecord::Migration[7.2]
  def change
    add_column :games, :seed, :string
    add_column :games, :version, :string
    add_column :games, :game_data, :json, default: {}
    add_column :games, :result, :json, default: {}
  end
end
