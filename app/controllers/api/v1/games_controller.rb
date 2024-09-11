class Api::V1::GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def create
    @game = Game.new(status: "playing")
    unless @game.save
      return  render json: { error: @game.errors.full_messages }
    end

    # generate a random seed
    @game.seed = SecureRandom.hex(16)

    unless @game.save
      render json: { error: @game.errors.full_messages }
    end
  end

  def play
    @game = Game.find(params[:id])
    @game.play

    return render status: :unprocessable_entity, json: { error: @game.errors.full_messages } if @game.errors.any?

    @message = "你選擇了礦工"
  end
end
