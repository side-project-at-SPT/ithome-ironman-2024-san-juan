json.games @games do |game|
  json.partial! "api/v1/games/game", game: game
end
