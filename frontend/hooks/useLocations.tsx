import useSWR from "swr";

export type Location = {
  slug: string;
  name: string;
  id: number;
};

export const LOCATIONS_ERROR_MESSAGE =
  "We couldn't load the locations. Please reload the page.";

export const LOCATION_MISSING_MESSAGE = "We couldn't find that location.";

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
