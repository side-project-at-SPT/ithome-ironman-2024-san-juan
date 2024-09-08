class Game < ApplicationRecord
  enum :status, {
    unknown: 0,
    playing: 1,
    finished: 2
  }, prefix: true
end
