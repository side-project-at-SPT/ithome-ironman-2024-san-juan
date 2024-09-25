class LobbyChannel < ApplicationCable::Channel
  def subscribed
    stream_from "lobby_channel"
    data = { message: "Hello, #{current_user.email}!" }
    ActionCable.server.broadcast "lobby_channel", data
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    ActionCable.server.broadcast "lobby_channel", message: data
  end

  def create_room
    room = Kredis.string "room:#{SecureRandom.hex(4)}"
    room.value = "Room #{room.key}"
    room_owner = Kredis.string "#{room.key}:owner"
    room_owner.value = current_user.email
    room_participants = Kredis.set "#{room.key}:participants"
    room_participants.add current_user.email
    message = { message: "#{room.value} created!" }
    ActionCable.server.broadcast "lobby_channel", message
  end

  def get_rooms
    rooms = $redis.scan_each(match: "room:*").map do |room|
      room_name = room.split(":")[1]
      room_name
    end
    message = { rooms: rooms.uniq }
    ActionCable.server.broadcast "lobby_channel", message
  end

  def get_participant_rooms
    # Get all rooms where the current user is a participant
    rooms = $redis.scan_each(match: "room:*:participants").map do |room|
      if $redis.smembers(room).include? current_user.email
        room_name = room.split(":")[1]
        room_name
      end
    end
    rooms.compact!
    message = { rooms: rooms.uniq }
    ActionCable.server.broadcast "lobby_channel", message
  end

  def leave_room(params)
    action = params["action"]
    room_key = params["room"]
    # can not leave room if you are not in the room
    room_participants = Kredis.set "room:#{room_key}:participants"
    if room_participants.include? current_user.email
      # close room if you are the owner
      room_owner = Kredis.string "room:#{room_key}:owner"
      if room_owner.value == current_user.email
        room = Kredis.string "room:#{room_key}"
        room_owner = Kredis.string "room:#{room_key}:owner"

        room_participants.clear
        room_owner.clear
        room.clear
        # Kredis.del "room:#{room_key}"
        # Kredis.del "room:#{room_key}:owner"
        # Kredis.del "room:#{room_key}:participants"
        message = { message: "Room #{room_key} closed!" }
        ActionCable.server.broadcast "lobby_channel", message
      else
        room_participants.remove current_user.email
        message = { message: "You have left room #{room_key}" }
        ActionCable.server.broadcast "lobby_channel", message
      end
    else
      message = { message: "You are not in room #{room_key}" }
      ActionCable.server.broadcast "lobby_channel", message
    end
  end

  def clear_rooms
    count = 0
    $redis.scan_each(match: "room:*").each do |room|
      $redis.del room
      count += 1
    end
    message = { message: "#{count} rooms cleared!" }
    ActionCable.server.broadcast "lobby_channel", message
  end

  # Deprecated
  def join_room(params)
    deprecated_notice = "This method is deprecated. Please use RoomChannel#subscribed instead."
    message = { message: deprecated_notice }
    ActionCable.server.broadcast "lobby_channel", message
  end

  # Deprecated
  def show_room_info(params)
    deprecated_notice = "This method is deprecated. Please use RoomChannel#info instead."
    message = { message: deprecated_notice }
    ActionCable.server.broadcast "lobby_channel", message
  end

  # Deprecated
  def start_new_game(params)
    deprecated_notice = "This method is deprecated. Please use RoomChannel#play instead."
    message = { message: deprecated_notice }
    ActionCable.server.broadcast "lobby_channel", message
  end
end
