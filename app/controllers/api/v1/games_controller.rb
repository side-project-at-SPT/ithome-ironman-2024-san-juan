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

    # - 選完職業，更新遊戲狀態
    # - 判斷有沒有什麼動作可以由系統接續自動執行
    # - 如果有，回傳 202
    # - 如果沒有，回傳 204

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
