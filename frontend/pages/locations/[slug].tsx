import { useRouter } from "next/router";

import { LocationWeather } from "../../components/LocationWeather";

export default function WeatherPage() {
  const router = useRouter();

  return <LocationWeather slug={router.query.slug as string} />;
}
