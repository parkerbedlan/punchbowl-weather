OpenWeather::Client.configure do |config|
  # In a real codebase we wouldn't want to hardcode an api key, but for this challenge assume it's okay here
  config.api_key    = 'de4bdb6096bacefbf8f9f63118d1fadf'
  config.units      = 'imperial'
end
