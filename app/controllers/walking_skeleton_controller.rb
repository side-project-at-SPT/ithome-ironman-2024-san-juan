class WalkingSkeletonController < ApplicationController
  def show
    respond_to do |format|
      format.json { render json: { message: "Walk #{Time.current}" } }
      format.html { render plain: "Server is up and running -- #{Time.current}" }
    end
  end
end
