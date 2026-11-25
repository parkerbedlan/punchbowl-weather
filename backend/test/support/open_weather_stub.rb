module OpenWeatherStub
  class FakeClient
    attr_reader :call_count, :place_queries

    def initialize(payload_or_error, places_or_error)
      @payload_or_error = payload_or_error
      @places_or_error = places_or_error
      @call_count = 0
      @call_count_lock = Mutex.new
      @place_queries = []
    end

    def current_weather(lat:, lon:)
      @call_count_lock.synchronize { @call_count += 1 }
      raise @payload_or_error if @payload_or_error.is_a?(Exception)

      OpenWeather::Models::City::Weather.new(@payload_or_error)
    end

    def get(_path, options)
      @place_queries << options.fetch(:q)
      raise @places_or_error if @places_or_error.is_a?(Exception)

      @places_or_error
    end
  end

  def open_weather_payload
    JSON.parse(file_fixture('open_weather_current_weather.json').read)
  end

  def open_weather_place(name, state, country, lat: 1.5, lon: 2.5)
    { 'name' => name, 'state' => state, 'country' => country, 'lat' => lat, 'lon' => lon }.compact
  end

  def open_weather_refusal(status)
    OpenWeather::Errors::Fault.new(status:, headers: {}, body: { 'cod' => status })
  end

  def pause_open_weather_calls(until_time: 5.minutes.from_now)
    OpenWeatherAccount.current.update!(calls_paused_until: until_time)
  end

  def with_open_weather(payload_or_error = open_weather_payload, places: [])
    client = FakeClient.new(payload_or_error, places)
    OpenWeather::Client.define_singleton_method(:new) { client }
    yield client
  ensure
    OpenWeather::Client.singleton_class.remove_method(:new)
  end
end
