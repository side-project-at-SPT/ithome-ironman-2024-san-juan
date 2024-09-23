class Api::V1::GamesController < ApplicationController
  before_action :set_game, only: %i[restart assign show]

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
    # HACK: show the players is bot or not
    pp @game.players.map { |player| player[:is_bot] ? "bot" : "human" }

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
    # - variant: np: should automatically step to the next player? (0: false, else: true, default: true)
    #            ex: POST /api/v1/games/1/roles/producer?np=0, will not step to the next player
    result.resolve_post_action(game: @game, options: { np: params[:np] != "0" })

    # notify the next player to take action
    # TODO: implement this

    @message = "你選擇了: #{params[:role]}"
    render :show
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end
end
