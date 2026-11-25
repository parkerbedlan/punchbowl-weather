class Api::Admin::LocationFavoriteCountsController < Api::Admin::BaseController
  def index
    render json: Locations::FavoriteCounts.new
  end
end
