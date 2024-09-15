json.ignore_nil!
json.id game.id
json.status game.status
if game.status_unknown?
  json.message "game not set up yet"
else
  json.game_config do
    json.seed game.seed
  end
  json.game_data do
    json.current_price game.current_price
    json.supply_pile game.game_data["supply_pile"]
    json.current_player_index game.game_data["current_player_index"]
    json.players game.players do |player|
      json.id player.id
      json.hand player.hand
      json.buildings player.buildings do |building|
        json.id building.id
        json.good_id building.good_id
        json.card_ids building.card_ids
      end
    end
  end
end
