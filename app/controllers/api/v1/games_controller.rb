class Api::V1::GamesController < ApplicationController
  before_action :set_game, only: %i[restart assign play]

  def index
    @games = Game.all
  end

  def create
    @game = Game.start_new_game(seed: params[:seed])

    render json: { error: @game.errors.full_messages } unless @game.present?
  end

  def restart
    @game.restart

    return render status: :unprocessable_entity, json: { error: @game.errors.full_messages } if @game.errors.any?

    @message = "遊戲重新開始"

    render json: { message: @message }
  end

  def assign
    # TODO: assign role to the current player
    # - currently, we don't have a real player. Use a dummy player instead.
    @current_player ||= "dummy player"

    # - 選完職業，更新遊戲狀態
    res = @game.assign_role(role: params[:role], player: @current_player)
    if res.errors.any?
      return render status: :unprocessable_entity, json: {
        error: res.errors.full_messages
      }
    end

    # experiment: use post_action to connect the next action
    # or use queue to store and execute the next actions
    counter = 0
    while counter < 3 && res.post_action.present? do
      pp counter
      counter += 1
      # puts "post_action present"
      # pp res.post_action
      res = res.exec_post_action(game_id: @game.id)
    end

    puts "post_action not present"

    # - 判斷有沒有什麼動作可以由系統接續自動執行
    # - 如果有，回傳 202
    # - 如果沒有，回傳 204

    @message = "你選擇了: #{params[:role]}"
    render json: { message: @message }
  end

  def play
    @game.play

    return render status: :unprocessable_entity, json: { error: @game.errors.full_messages } if @game.errors.any?

    @message = "你選擇了礦工"
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end
end
