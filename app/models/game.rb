class Game < ApplicationRecord
  enum :status, {
    unknown: 0,
    playing: 1,
    finished: 2
  }, prefix: true

  def play
    return errors.add(:status, "can't be blank") unless status_playing?

    self.status_finished!
  end
end
