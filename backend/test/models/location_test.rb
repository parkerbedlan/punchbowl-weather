require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test "can initialize location" do
    location = Location.new(slug: 'new_york', name: 'New York', lat: 40.7128, lon: -74.0060)
    assert_instance_of Location, location
    assert_equal 'New York', location.name
    assert_in_delta 40.7128, location.lat
    assert_in_delta(-74.0060, location.lon)
  end

  test "list returns every location" do
    locations = Location.list
    assert_equal %w[boston new_york], locations.map(&:slug).sort
  end

  test "get location by id" do
    location = Location.get(:boston)
    assert_equal 'Boston, Massachusetts', location.name
  end

  test "get returns nil for a slug with no location" do
    assert_nil Location.get(:atlantis)
  end

  test "slug is unique" do
    location = Location.new(slug: 'boston', name: 'Boston again')
    assert_not location.valid?
    assert_includes location.errors[:slug], 'has already been taken'
  end

  test "name is unique" do
    location = Location.new(slug: 'boston_again', name: 'Boston, Massachusetts')
    assert_not location.valid?
    assert_includes location.errors[:name], 'has already been taken'
  end

  test "find_or_create_for_place returns a saved location without an OpenWeather request" do
    with_open_weather do |client|
      location = Location.find_or_create_for_place(city: 'Boston', state: 'Massachusetts', country: 'US')

      assert_equal locations(:boston), location
      assert_empty client.place_queries
    end
  end

  test "find_or_create_for_place saves a new place with the coordinates OpenWeather gives" do
    places = [open_weather_place('Springfield', 'Missouri', 'US', lat: 37.2082, lon: -93.2923)]

    with_open_weather(places:) do
      location = Location.find_or_create_for_place(city: 'Springfield', state: 'Missouri', country: 'US')

      assert location.previously_new_record?
      assert_equal 'Springfield, Missouri', location.name
      assert_equal 'springfield_missouri', location.slug
      assert_in_delta 37.2082, location.lat
      assert_in_delta(-93.2923, location.lon)
    end
  end

  test "find_or_create_for_place saves nothing for a place OpenWeather does not know" do
    with_open_weather(places: []) do
      assert_no_difference 'Location.count' do
        assert_nil Location.find_or_create_for_place(city: 'Atlantis', state: nil, country: 'US')
      end
    end
  end

  test "find_or_create_for_place returns the saved location when two requests add the same place" do
    places = [open_weather_place('Springfield', 'Missouri', 'US')]
    saved_by_other_request = nil
    find_by_name = Location.method(:find_by)
    Location.define_singleton_method(:find_by) do |*arguments, **conditions|
      found = find_by_name.call(*arguments, **conditions)
      saved_by_other_request ||= Location.create!(name: 'Springfield, Missouri', slug: 'springfield_missouri') if found.nil?
      found
    end

    with_open_weather(places:) do
      location = Location.find_or_create_for_place(city: 'Springfield', state: 'Missouri', country: 'US')

      assert_equal saved_by_other_request, location
    end
  ensure
    Location.singleton_class.remove_method(:find_by)
  end

  test "find_or_create_for_place raises when the new slug belongs to a place with another name" do
    Location.create!(name: 'Saint Louis, Missouri', slug: 'saint_louis_missouri')

    with_open_weather(places: [open_weather_place('Saint-Louis', 'Missouri', 'US')]) do
      assert_raises ActiveRecord::RecordInvalid do
        Location.find_or_create_for_place(city: 'Saint-Louis', state: 'Missouri', country: 'US')
      end
    end
  end
end
