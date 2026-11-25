import useSWR from "swr";

export type LocationFavoriteCounts = {
  id: number;
  slug: string;
  name: string;
  counts: Array<number>;
};

type LocationFavoriteCountsResponse = {
  days: Array<string>;
  locations: Array<LocationFavoriteCounts>;
};

export const FAVORITE_COUNTS_ERROR_MESSAGE =
  "We couldn't load the favorite counts. Please reload the page.";

const FAVORITE_COUNTS_URL = `${process.env.NEXT_PUBLIC_API_BASE}/api/admin/location_favorite_counts`;

const fetcher = async (path: string): Promise<LocationFavoriteCountsResponse> => {
  const response = await fetch(path);
  if (!response.ok) {
    throw new Error(`The favorite counts request failed with HTTP ${response.status}`);
  }

  return response.json();
};

export const useLocationFavoriteCounts = (isAdmin: boolean) => {
  const { data, error } = useSWR<LocationFavoriteCountsResponse, Error>(
    isAdmin ? FAVORITE_COUNTS_URL : null,
    fetcher
  );

  return {
    days: data?.days,
    locations: data?.locations,
    isError: !data && Boolean(error),
  };
};

export const formatDay = (day: string) =>
  new Date(`${day}T00:00:00Z`).toLocaleDateString("en-US", {
    month: "short",
    day: "numeric",
    timeZone: "UTC",
  });

export default useLocationFavoriteCounts;
