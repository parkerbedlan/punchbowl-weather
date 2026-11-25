import { LocationWeather } from "../components/LocationWeather";

const DEFAULT_LOCATION_SLUG = "new_york";

export default function Home() {
  return <LocationWeather slug={DEFAULT_LOCATION_SLUG} />;
}
