import { useState } from "react";
import { useRouter } from "next/router";
import {
  Combobox,
  ComboboxInput,
  ComboboxOption,
  ComboboxOptions,
} from "@headlessui/react";
import { MagnifyingGlassIcon } from "@heroicons/react/24/outline";

import {
  LOCATION_SEARCH_ERROR_MESSAGE,
  LocationCandidate,
  SHORTEST_QUERY_LENGTH,
  useLocationCandidates,
} from "../hooks/useLocationCandidates";
import { LOCATION_ADD_ERROR_MESSAGE, useAddLocation } from "../hooks/useLocations";

const SEARCH_LABEL = "Search for a city";

export const LocationSearch = () => {
  const router = useRouter();
  const addLocation = useAddLocation();
  const [query, setQuery] = useState("");
  const [isAdding, setIsAdding] = useState(false);
  const [addFailed, setAddFailed] = useState(false);
  const { candidates, isLongEnough, isSearching, isError } =
    useLocationCandidates(query);

  const openLocation = async (candidate: LocationCandidate | null) => {
    if (!candidate) return;

    setIsAdding(true);
    setAddFailed(false);
    try {
      const location = await addLocation(candidate);
      await router.push(`/locations/${location.slug}`);
    } catch {
      setAddFailed(true);
    } finally {
      setIsAdding(false);
    }
  };

  const searchStatus = () => {
    if (!isLongEnough) return `Type ${SHORTEST_QUERY_LENGTH} or more letters.`;
    if (isSearching) return "Searching...";
    if (isError) return LOCATION_SEARCH_ERROR_MESSAGE;
    if (candidates?.length === 0) return "No cities found.";

    return null;
  };
  const status = searchStatus();

  return (
    <div className="flex flex-1 items-center px-4">
      <Combobox
        value={null}
        onChange={openLocation}
        onClose={() => setQuery("")}
        disabled={isAdding}
      >
        <div className="relative w-full max-w-md">
          <MagnifyingGlassIcon
            className="pointer-events-none absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-gray-400"
            aria-hidden="true"
          />
          <ComboboxInput
            className="w-full rounded-md border-gray-300 pl-10 text-sm focus:border-indigo-500 focus:ring-indigo-500 disabled:opacity-50"
            placeholder={SEARCH_LABEL}
            aria-label={SEARCH_LABEL}
            autoComplete="off"
            onChange={(event) => {
              setQuery(event.target.value);
              setAddFailed(false);
            }}
          />
          <ComboboxOptions
            anchor={{ to: "bottom start", gap: 4 }}
            className="z-20 w-(--input-width) rounded-md bg-white py-1 text-sm shadow-lg ring-1 ring-black/5"
          >
            {status ? (
              <div className="px-3 py-2 text-gray-500">{status}</div>
            ) : (
              candidates.map((candidate) => (
                <ComboboxOption
                  key={candidate.name}
                  value={candidate}
                  className="cursor-pointer px-3 py-2 text-gray-900 data-focus:bg-indigo-600 data-focus:text-white"
                >
                  {candidate.name}
                </ComboboxOption>
              ))
            )}
          </ComboboxOptions>
          {addFailed && (
            <p
              role="alert"
              className="absolute left-0 top-full mt-1 w-full rounded-md bg-white px-3 py-2 text-sm text-red-600 shadow-lg ring-1 ring-black/5"
            >
              {LOCATION_ADD_ERROR_MESSAGE}
            </p>
          )}
        </div>
      </Combobox>
    </div>
  );
};

export default LocationSearch;
