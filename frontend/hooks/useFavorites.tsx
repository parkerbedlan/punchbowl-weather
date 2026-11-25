import { useState } from "react";
import useSWR from "swr";

export type UserFavorite = {
  id: number;
  location_id: number;
  user_id: number;
};

export const FAVORITE_ERROR_MESSAGE =
  "We couldn't update your favorites. Please try again.";

const FAVORITES_URL = `${process.env.NEXT_PUBLIC_API_BASE}/api/user_favorites`;

const fetcher = async (path: string) => {
  const response = await fetch(path);
  if (!response.ok) {
    throw new Error(`The favorites request failed with HTTP ${response.status}`);
  }

  return response.json();
};

export const useUserFavorites = () => {
  const { data, error, mutate } = useSWR<Array<UserFavorite>, Error>(
    FAVORITES_URL,
    fetcher
  );

  return {
    favorites: data,
    isLoading: !data && !error,
    isError: error,
    mutate
  };
};

const requestToggle = (locationId: number, isFavorite: boolean) =>
  isFavorite
    ? fetch(`${FAVORITES_URL}/${locationId}`, { method: "DELETE" })
    : fetch(FAVORITES_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ location_id: locationId }),
      });

export const useFavoriteToggle = (locationId: number) => {
  const { favorites, mutate } = useUserFavorites();
  const [isPending, setIsPending] = useState(false);

  const isFavorite =
    favorites?.some((favorite) => favorite.location_id === locationId) ?? false;

  const toggle = async () => {
    setIsPending(true);
    try {
      const response = await requestToggle(locationId, isFavorite);
      if (!response.ok) return false;

      await mutate();
      return true;
    } catch {
      return false;
    } finally {
      setIsPending(false);
    }
  };

  return { isFavorite, isDisabled: isPending || !favorites, toggle };
};
