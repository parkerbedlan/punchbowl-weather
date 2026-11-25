import useSWR, { useSWRConfig } from "swr";

import { LocationCandidate } from "./useLocationCandidates";

export type Location = {
  slug: string;
  name: string;
  id: number;
};

export const LOCATIONS_ERROR_MESSAGE =
  "We couldn't load the locations. Please reload the page.";

export const LOCATION_MISSING_MESSAGE = "We couldn't find that location.";

export const LOCATION_ADD_ERROR_MESSAGE =
  "We couldn't add that location. Please try again.";

const LOCATIONS_URL = `${process.env.NEXT_PUBLIC_API_BASE}/api/locations`;

const fetcher = async (path: string) => {
  const response = await fetch(path);
  if (!response.ok) {
    throw new Error(`The locations request failed with HTTP ${response.status}`);
  }

  return response.json();
};

export const useLocations = () => {
  const { data, error } = useSWR<Array<Location>, Error>(
    LOCATIONS_URL,
    fetcher
  );

  return {
    locations: data,
    isLoading: !data && !error,
    isError: !data && Boolean(error),
  };
};

export const useLocation = (slug?: string) => {
  const { locations, isError } = useLocations();
  const location = locations?.find((location) => location.slug === slug);

  return {
    location,
    isMissing: Boolean(slug && locations && !location),
    isError,
  };
};

export const useAddLocation = () => {
  const { mutate } = useSWRConfig();

  return async ({ city, state, country }: LocationCandidate) => {
    const response = await fetch(LOCATIONS_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ place: { city, state, country } }),
    });
    if (!response.ok) {
      throw new Error(`The add location request failed with HTTP ${response.status}`);
    }

    const location: Location = await response.json();
    await mutate(LOCATIONS_URL);

    return location;
  };
};
