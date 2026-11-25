module OpenWeatherStub
  class FakeClient
    attr_reader :call_count

    def initialize(payload_or_error)
      @payload_or_error = payload_or_error
      @call_count = 0
      @call_count_lock = Mutex.new
    end

    def current_weather(lat:, lon:)
      @call_count_lock.synchronize { @call_count += 1 }
      raise @payload_or_error if @payload_or_error.is_a?(Exception)

      OpenWeather::Models::City::Weather.new(@payload_or_error)
    end
  end

  def open_weather_payload
    JSON.parse(file_fixture('open_weather_current_weather.json').read)
  end

  def with_open_weather(payload_or_error)
    client = FakeClient.new(payload_or_error)
    OpenWeather::Client.define_singleton_method(:new) { client }
    yield client
  ensure
    OpenWeather::Client.singleton_class.remove_method(:new)
  end
end
