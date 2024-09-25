class RoomChannel < ApplicationCable::Channel
  def subscribed
    @room_id = params[:room_id]

    reject and return if @room_id.blank?

    @channel = "room_#{@room_id}_channel"
    stream_from @channel
    data = { message: "#{current_user.email} has joined the room" }
    ActionCable.server.broadcast @channel, data
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end

  # - 加入房間 subscribed
  # - 查詢房間有誰 info
  # - 開始遊戲 play
  # - 離開房間 unsubscribed
  # - 關閉房間 if invoker is room creator, then close room

  def info
    room = Kredis.string "room:#{@room_id}"
    room_owner = Kredis.string "room:#{@room_id}:owner"
    room_participants = Kredis.set "room:#{@room_id}:participants"
    message = {
      message: "Room #{room.value} info: owner - #{room_owner.value}, participants - #{room_participants.members.to_sentence}",
      owner: room_owner.value,
      participants: room_participants.members
    }
    ActionCable.server.broadcast @channel, message
  end

  def play
    room_owner = Kredis.string "room:#{@room_id}:owner"

    case room_owner.value
    when nil
      # room does not exist
      message = { message: "Room #{@room_id} does not exist" }
      ActionCable.server.broadcast @channel, message
    when current_user.email
      # room owner
      room_participants = Kredis.set "room:#{@room_id}:participants"
      game = Game.start_new_game(players: room_participants.members)
      message = { message: "Game started in room #{@room_id}", game_id: game.id }
      ActionCable.server.broadcast @channel, message
    else
      message = { message: "Only the room owner can start the game" }
      ActionCable.server.broadcast @channel, message
    end
  end
end
