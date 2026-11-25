module Locations
  class Candidate
    attr_reader :city, :country, :lat, :lon, :state

    # https://openweathermap.org/api/geocoding-api
    def self.search(query)
      return [] if query.blank?

      places = OpenWeatherAccount.current.call do |client|
        client.get('direct', endpoint: 'https://api.openweathermap.org/geo/1.0', q: query, limit: 5)
      end

      places
        .map { new(city: it['name'], state: it['state'], country: it['country'], lat: it['lat'], lon: it['lon']) }
        .uniq(&:name)
    end

    def self.find(city:, country:, state: nil)
      name = new(city:, state:, country:).name

      search([city, state, country].compact_blank.join(',')).find { it.name == name }
    end

    def initialize(city:, country:, state: nil, lat: nil, lon: nil)
      @city = city
      @state = state
      @country = country
      @lat = lat
      @lon = lon
    end

    def name
      [city, state, (country unless country == 'US')].compact_blank.join(', ')
    end
  end
end
