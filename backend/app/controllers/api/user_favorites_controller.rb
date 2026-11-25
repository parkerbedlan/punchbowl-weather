class Api::UserFavoritesController < ApplicationController
  def index
    # An empty list rather than an error when no user exists, so the frontend
    # renders normally before anyone has been created.
    return render json: [] if current_user.nil?

    render json: current_user.user_favorites.as_json(only: FAVORITE_FIELDS)
  end

  def create
    return head :not_found if current_user.nil?

    favorite = current_user.user_favorites.create(location_id: params[:location_id])

    render json: favorite.as_json(only: FAVORITE_FIELDS), status: :created
  end

  def destroy
    favorite = current_user.user_favorites.find_by(location_id: params[:id])

    favorite.destroy
    head :no_content
  end

  private

  # The shape the frontend expects; see the UserFavorite type in
  # frontend/hooks/useFavorites.tsx.
  FAVORITE_FIELDS = [:id, :location_id, :user_id].freeze
end
