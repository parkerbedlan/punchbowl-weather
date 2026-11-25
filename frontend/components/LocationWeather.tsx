import { useContext, useEffect } from "react";

import FavoriteButton from "./FavoriteButton";
import { LocationHeading } from "./LocationHeading";
import { SessionContext } from "./SessionProvider";
import { CurrentWeather } from "./CurrentWeather";
import { useLocation } from "../hooks/useLocations";
import { useWeather } from "../hooks/useWeather";

export const LocationWeather = ({ slug }: { slug: string }) => {
  const { setLocationSlug } = useContext(SessionContext);
  const location = useLocation(slug);
  const { weather } = useWeather(slug);

  useEffect(() => {
    setLocationSlug(slug);
  }, [slug]);

  return (
    <div className="space-y-4">
      <LocationHeading name={location?.name} />
      {location && <FavoriteButton key={location.id} location={location} />}
      <CurrentWeather weather={weather} />
    </div>
  );
};

export default LocationWeather;
