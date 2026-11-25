class Api::CurrentUsersController < ApplicationController
  before_action :require_current_user

  def show
    render json: current_user.as_json(only: [:id, :role])
  end
end
