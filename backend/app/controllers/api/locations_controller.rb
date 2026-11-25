class Api::LocationsController < ApplicationController
  def index
    render json: Location.list.as_json(only: LOCATION_FIELDS)
  end

  def show
    location = Location.get(params[:id])
    return head :not_found if location.nil?

    render json: location.as_json(only: LOCATION_FIELDS)
  end

  private

  # The shape the frontend expects; see the Location type in
  # frontend/hooks/useLocations.tsx. Coordinates are an implementation detail
  # of the weather lookup and are not exposed.
  LOCATION_FIELDS = [:id, :slug, :name].freeze
end
