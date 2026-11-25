class Api::UserFavoritesController < ApplicationController
  before_action :require_current_user, only: [:create, :destroy]

  def index
    # An empty list rather than an error when no user exists, so the frontend
    # renders normally before anyone has been created.
    return render json: [] if current_user.nil?

    render json: current_user.user_favorites.as_json(only: FAVORITE_FIELDS)
  end

  def create
    location = Location.find_by(id: params[:location_id])
    return head :not_found if location.nil?

    favorite = current_user.user_favorites.find_or_create_by!(location: location)

    render json: favorite.as_json(only: FAVORITE_FIELDS),
           status: favorite.previously_new_record? ? :created : :ok
  end

  def destroy
    current_user.user_favorites.where(location_id: params[:id]).destroy_all
    head :no_content
  end

  private

  # The shape the frontend expects; see the UserFavorite type in
  # frontend/hooks/useFavorites.tsx.
  FAVORITE_FIELDS = [:id, :location_id, :user_id].freeze
end
