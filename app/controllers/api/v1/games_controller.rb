class Api::V1::GamesController < ApplicationController
  before_action :set_game, only: %i[restart assign play]

  def index
    @games = Game.all
  end

  def show; end

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

    command = @game.build_assign_role_command(role: params[:role], player: @current_player)
    if command.errors.any?
      return render status: :bad_request, json: { error: command.errors.full_messages }
    end

    result = command.call
    if result.errors.any?
      return render status: :unprocessable_entity, json: { error: result.errors.full_messages }
    end

    # resolve the rest of the action can be done automatically
    result.resolve_post_action(game: @game)

    # notify the next player to take action
    # TODO: implement this
    @game.notify_next_turn

    @message = "你選擇了: #{params[:role]}"
    render :show
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
