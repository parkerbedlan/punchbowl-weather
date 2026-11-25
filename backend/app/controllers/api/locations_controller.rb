class Api::LocationsController < ApplicationController
  def index
    render json: Location.list.as_json(only: LOCATION_FIELDS)
  end

  def show
    location = Location.get(params[:id])
    return head :not_found if location.nil?

    render json: location.as_json(only: LOCATION_FIELDS)
  end

  def create
    location = Location.find_or_create_for_place(**place_params)
    return head :unprocessable_content if location.nil?

    render json: location.as_json(only: LOCATION_FIELDS),
           status: location.previously_new_record? ? :created : :ok
  rescue ActiveRecord::RecordInvalid
    head :unprocessable_content
  rescue Faraday::Error => error
    logger.warn "The OpenWeather place lookup failed with #{error.class} (HTTP #{error.response_status.inspect})"
    head :service_unavailable
  end

  private

  def place_params
    place = params.expect(place: [:city, :state, :country])
    city, country = place.require([:city, :country])

    { city:, country:, state: place[:state] }
  end

  # The shape the frontend expects; see the Location type in
  # frontend/hooks/useLocations.tsx. Coordinates are an implementation detail
  # of the weather lookup and are not exposed.
  LOCATION_FIELDS = [:id, :slug, :name].freeze
end
