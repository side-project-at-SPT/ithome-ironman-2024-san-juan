class Api::V1::GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def create
    @game = Game.start_new_game(seed: params[:seed])

    render json: { error: @game.errors.full_messages } unless @game.present?
  end

  def assign
    @game = Game.find(params[:id])
    @current_player ||= "dummy player"
    @game.assign_role(role: params[:role], player: @current_player)
    if @game.errors.any?
      return render status: :unprocessable_entity, json: {
        error: @game.errors.full_messages
      }
    end

    @message = "你選擇了: #{params[:role]}"
    render json: { message: @message }
  end

  def play
    @game = Game.find(params[:id])
    @game.play

    return render status: :unprocessable_entity, json: { error: @game.errors.full_messages } if @game.errors.any?

    @message = "你選擇了礦工"
  end
end
