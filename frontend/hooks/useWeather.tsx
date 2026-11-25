import useSWR from "swr";

export type Weather = {
  temperature: number;
  feelsLike: number;
  wind: number;
  humidity: number;
  description: string;
  icon: string;
  fetchedAt: string;
};

type WeatherResponse = {
  temperature: number;
  feels_like: number;
  wind_speed: number;
  humidity: number;
  description: string;
  icon_uri: string;
  fetched_at: string;
};

export const WEATHER_ERROR_MESSAGE =
  "We couldn't load the weather. We'll try again shortly.";

const REFRESH_INTERVAL_IN_MILLISECONDS = 60_000;
const FIRST_ERROR_RETRY_DELAY_IN_MILLISECONDS = 1_000;
const LONGEST_ERROR_RETRY_DELAY_IN_MILLISECONDS = 30_000;

const errorRetryDelay = (retryCount: number) => {
  const doubledDelay =
    FIRST_ERROR_RETRY_DELAY_IN_MILLISECONDS * 2 ** (retryCount - 1);
  const randomSpread = 0.5 + Math.random();

  return (
    Math.min(doubledDelay, LONGEST_ERROR_RETRY_DELAY_IN_MILLISECONDS) *
    randomSpread
  );
};

const fetcher = async (path: string): Promise<Weather> => {
  const response = await fetch(path);
  if (!response.ok) {
    throw new Error(`The weather request failed with HTTP ${response.status}`);
  }

  const data: WeatherResponse = await response.json();

  return {
    temperature: data.temperature,
    feelsLike: data.feels_like,
    wind: data.wind_speed,
    humidity: data.humidity,
    description: data.description,
    icon: data.icon_uri,
    fetchedAt: data.fetched_at,
  };
};

export const useWeather = (location_slug?: string) => {
  const { data, error } = useSWR<Weather, Error>(
    location_slug
      ? `${process.env.NEXT_PUBLIC_API_BASE}/api/locations/${location_slug}/weather`
      : null,
    fetcher,
    {
      refreshInterval: REFRESH_INTERVAL_IN_MILLISECONDS,
      onErrorRetry: (_error, _key, _config, revalidate, revalidateOptions) => {
        setTimeout(
          () => revalidate(revalidateOptions),
          errorRetryDelay(revalidateOptions.retryCount)
        );
      },
    }
  );

  return {
    weather: data,
    isLoading: !data && !error,
    isError: !data && Boolean(error),
  };
};

export default useWeather;
