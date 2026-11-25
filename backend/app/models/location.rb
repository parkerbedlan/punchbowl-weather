class Location < ApplicationRecord
  validates :slug, presence: true

  LOCATIONS = HashWithIndifferentAccess.new({
    new_york:    { id: 1, slug: 'new_york',    name: 'New York, New York',      lat: 40.7128, lon:  -74.0060 },
    boston:      { id: 2, slug: 'boston',      name: 'Boston, Massachusetts',   lat: 42.3601, lon:  -71.0589 },
    chicago:     { id: 3, slug: 'chicago',     name: 'Chicago, Illinois',       lat: 41.8781, lon:  -87.6298 },
    denver:      { id: 4, slug: 'denver',      name: 'Denver, Colorado',        lat: 39.7392, lon: -104.9903 },
    houston:     { id: 5, slug: 'houston',     name: 'Houston, Texas',          lat: 29.7604, lon:  -95.3698 },
    seattle:     { id: 6, slug: 'seattle',     name: 'Seattle, Washington',     lat: 47.6062, lon: -122.3321 },
    los_angeles: { id: 7, slug: 'los_angeles', name: 'Los Angeles, California', lat: 34.0522, lon: -118.2437 }
  })

  def self.list
    LOCATIONS.values.map { |attributes| self.new(attributes) }
  end

  def self.get(slug)
    self.new(LOCATIONS[slug])
  end

  def self.lookup(lat:, lon:)
    city = Geocoder.search([lat, lon]).first.city
    self.new(city, lat, lon)
  rescue
    nil
  end
end
