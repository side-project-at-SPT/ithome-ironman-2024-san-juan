class Room
  class << self
    def all
      $redis.scan_each(match: "room:*")
            .map { |room| room.split(":")[1] }
            .uniq
            .map { |id| new(id) }
    end

    def find_by_id(id)
      new(id) if Kredis.string("room:#{id}").value.present?
    end

    def find_or_create_by_id(id, email)
      if Kredis.string("room:#{id}").value.present?
        new(id)
      else
        create(id, email)
      end
    end

    def create(id, email)
      room = Kredis.string "room:#{id}"
      room.value = "Room #{room.key}"
      room_owner = Kredis.string "#{room.key}:owner"
      room_owner.value = email
      room_participants = Kredis.set "#{room.key}:participants"
      room_participants.add email
      message = { message: "#{room.value} created!" }
      ActionCable.server.broadcast "lobby_channel", message
      new(id)
    end

    def destroy_all
      keys = []
      $redis.scan_each(match: "room:*").each do |room|
        $redis.del room
        keys << room.split(":")[1]
      end

      message = { message: "#{keys.uniq} rooms cleared!" }
      ActionCable.server.broadcast "lobby_channel", message
    end
  end

  def initialize(id)
    @id = id
    read_from_redis
  end

  attr_reader :id, :owner, :participants, :name

  private

  def read_from_redis
    @name = Kredis.string("room:#{id}").value
    @owner = Kredis.string("room:#{id}:owner").value
    @participants = Kredis.set("room:#{id}:participants").members
  end
end
