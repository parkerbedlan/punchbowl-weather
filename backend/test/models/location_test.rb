require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test "can initialize location" do
    location = Location.new(slug: 'new_york', name: 'New York', lat: 40.7128, lon: -74.0060)
    assert_instance_of Location, location
    assert_equal 'New York', location.name
    assert_in_delta 40.7128, location.lat.to_f
    assert_in_delta(-74.0060, location.lon.to_f)
  end

  test "list returns every location" do
    locations = Location.list
    assert_equal Location::LOCATIONS.size, locations.size
    assert locations.all? { |location| location.is_a?(Location) }
  end

  test "get location by id" do
    location = Location.get(:boston)
    assert_equal 'Boston, Massachusetts', location.name
  end

  test "can lookup location by coordinates" do
    skip "makes a live geocoder request"
    location = Location.lookup(lat: 42.2793, lon: -71.4162)
    assert_match /^Framingham/, location.name
  end

  test "location lookup return city and state" do
    skip
    location = Location.lookup(lat: 42.2793, lon: -71.4162)
    assert_equal 'Framingham, Massachusetts', location.name
  end

  test "lookup returns nil for invalid coordinates" do
    assert_nil Location.lookup(lat: nil, lon: nil)
  end
end
