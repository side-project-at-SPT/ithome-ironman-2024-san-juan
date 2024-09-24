class Api::V1::SessionsController < ApplicationController
  def create
    id = Time.now.to_i
    token = JWT.encode({ sub: id }, Rails.application.secret_key_base)

    render json: { status: :created, token: token }
  end

  def destroy
  end
end
