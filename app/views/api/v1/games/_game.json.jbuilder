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
  end
end
