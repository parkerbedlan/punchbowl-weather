import { LocationWeather } from "../components/LocationWeather";
import { useLocations } from "../hooks/useLocations";

export default function Home() {
  const { locations } = useLocations();

  return <LocationWeather slug={locations?.[0]?.slug} />;
}
