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
end
