class Api::LocationCandidatesController < ApplicationController
  def index
    candidates = Locations::Candidate.search(params[:query])

    render json: candidates.map { { name: it.name, city: it.city, state: it.state, country: it.country } }
  rescue Faraday::Error => error
    logger.warn "The OpenWeather place search failed with #{error.class} (HTTP #{error.response_status.inspect})"
    head :service_unavailable
  end
end
