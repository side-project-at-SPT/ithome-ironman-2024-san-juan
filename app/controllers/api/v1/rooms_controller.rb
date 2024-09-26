class Api::V1::RoomsController < ApplicationController
  def index
    @rooms = Room.all
  end

  def show
    @room = Room.find_by_id(params[:id])
    render status: :not_found, json: {
      error: "Room not found"
    } if @room.nil?
  end

  def destroy_all
    Room.destroy_all
  end
end
