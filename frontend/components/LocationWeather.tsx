import { useContext, useEffect } from "react";

import FavoriteButton from "./FavoriteButton";
import { LocationHeading } from "./LocationHeading";
import { SessionContext } from "./SessionProvider";
import { CurrentWeather } from "./CurrentWeather";
import {
  LOCATIONS_ERROR_MESSAGE,
  LOCATION_MISSING_MESSAGE,
  useLocation,
} from "../hooks/useLocations";
import { WEATHER_ERROR_MESSAGE, useWeather } from "../hooks/useWeather";

export const LocationWeather = ({ slug }: { slug?: string }) => {
  const { setLocationSlug } = useContext(SessionContext);
  const { location, isMissing, isError } = useLocation(slug);
  const { weather, isError: isWeatherError } = useWeather(slug);

  useEffect(() => {
    setLocationSlug(slug);
  }, [slug]);

  if (isError || isMissing) {
    return (
      <p role="alert" className="text-center text-gray-700">
        {isError ? LOCATIONS_ERROR_MESSAGE : LOCATION_MISSING_MESSAGE}
      </p>
    );
  }

  return (
    <div className="space-y-4">
      <LocationHeading name={location?.name} />
      {location && <FavoriteButton key={location.id} location={location} />}
      <CurrentWeather weather={weather} />
      {isWeatherError && (
        <p role="alert" className="text-center text-gray-700">
          {WEATHER_ERROR_MESSAGE}
        </p>
      )}
    </div>
  );
};

export default LocationWeather;
