require 'test_helper'

class Locations::CandidateTest < ActiveSupport::TestCase
  test 'search returns the places OpenWeather finds' do
    places = [
      open_weather_place('Springfield', 'Illinois', 'US', lat: 39.799, lon: -89.644),
      open_weather_place('Springfield', 'Missouri', 'US', lat: 37.2082, lon: -93.2923)
    ]

    with_open_weather(places:) do |client|
      candidates = Locations::Candidate.search('springfield')

      assert_equal ['Springfield, Illinois', 'Springfield, Missouri'], candidates.map(&:name)
      assert_equal [[39.799, -89.644], [37.2082, -93.2923]], candidates.map { [it.lat, it.lon] }
      assert_equal ['springfield'], client.place_queries
    end
  end

  test 'a place in the United States is named by its city and state' do
    assert_equal 'Chicago, Illinois', Locations::Candidate.new(city: 'Chicago', state: 'Illinois', country: 'US').name
  end

  test 'a place outside the United States is named with its country' do
    assert_equal 'London, England, GB', Locations::Candidate.new(city: 'London', state: 'England', country: 'GB').name
  end

  test 'a place with no state is named by its city and country' do
    assert_equal 'Tokyo, JP', Locations::Candidate.new(city: 'Tokyo', country: 'JP').name
  end

  test 'search returns one candidate for places with the same name' do
    places = [
      open_weather_place('Chic', 'Occitania', 'FR', lat: 43.2377, lon: 1.3216),
      open_weather_place('Chic', 'Occitania', 'FR', lat: 43.6207, lon: -0.2053)
    ]

    with_open_weather(places:) do
      candidates = Locations::Candidate.search('chic')

      assert_equal ['Chic, Occitania, FR'], candidates.map(&:name)
      assert_in_delta 43.2377, candidates.first.lat
    end
  end

  test 'search with no text makes no OpenWeather request' do
    with_open_weather do |client|
      assert_empty Locations::Candidate.search(' ')
      assert_empty client.place_queries
    end
  end

  test 'find asks OpenWeather for the city, state, and country' do
    places = [
      open_weather_place('London', 'England', 'GB', lat: 51.5074, lon: -0.1278),
      open_weather_place('City of London', 'England', 'GB', lat: 51.5156, lon: -0.092)
    ]

    with_open_weather(places:) do |client|
      candidate = Locations::Candidate.find(city: 'City of London', state: 'England', country: 'GB')

      assert_equal 'City of London, England, GB', candidate.name
      assert_in_delta 51.5156, candidate.lat
      assert_equal ['City of London,England,GB'], client.place_queries
    end
  end

  test 'find leaves a missing state out of the request' do
    with_open_weather(places: [open_weather_place('Tokyo', nil, 'JP')]) do |client|
      assert_equal 'Tokyo, JP', Locations::Candidate.find(city: 'Tokyo', state: '', country: 'JP').name
      assert_equal ['Tokyo,JP'], client.place_queries
    end
  end

  test 'find returns nil when OpenWeather has no place with that name' do
    with_open_weather(places: [open_weather_place('Albany Park', 'Illinois', 'US')]) do
      assert_nil Locations::Candidate.find(city: 'New York', state: 'New York', country: 'US')
    end
  end
end
