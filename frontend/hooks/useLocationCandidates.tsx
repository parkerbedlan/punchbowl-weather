import { useEffect, useState } from "react";
import useSWR from "swr";

export type LocationCandidate = {
  name: string;
  city: string;
  state: string | null;
  country: string;
};

export const LOCATION_SEARCH_ERROR_MESSAGE =
  "We couldn't search for cities. Please try again.";

export const SHORTEST_QUERY_LENGTH = 3;

const TYPING_PAUSE_IN_MILLISECONDS = 300;

const CANDIDATES_URL = `${process.env.NEXT_PUBLIC_API_BASE}/api/location_candidates`;

const fetcher = async (path: string) => {
  const response = await fetch(path);
  if (!response.ok) {
    throw new Error(`The city search failed with HTTP ${response.status}`);
  }

  return response.json();
};

const useValueAfterTypingPause = (value: string) => {
  const [valueAfterPause, setValueAfterPause] = useState(value);

  useEffect(() => {
    const timer = setTimeout(
      () => setValueAfterPause(value),
      TYPING_PAUSE_IN_MILLISECONDS
    );

    return () => clearTimeout(timer);
  }, [value]);

  return valueAfterPause;
};

export const useLocationCandidates = (typedQuery: string) => {
  const query = typedQuery.trim();
  const searchedQuery = useValueAfterTypingPause(query);
  const isLongEnough = query.length >= SHORTEST_QUERY_LENGTH;
  const isSearched = isLongEnough && query === searchedQuery;

  const { data, error } = useSWR<Array<LocationCandidate>, Error>(
    isSearched
      ? `${CANDIDATES_URL}?query=${encodeURIComponent(searchedQuery)}`
      : null,
    fetcher,
    {
      revalidateIfStale: false,
      revalidateOnFocus: false,
      revalidateOnReconnect: false,
      shouldRetryOnError: false,
    }
  );

  return {
    candidates: isSearched ? data : undefined,
    isLongEnough,
    isSearching: isLongEnough && (!isSearched || (!data && !error)),
    isError: isSearched && !data && Boolean(error),
  };
};
