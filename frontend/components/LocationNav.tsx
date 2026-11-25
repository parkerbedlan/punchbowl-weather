import { useContext, useState } from "react";
import Link from "next/link";
import { MapPinIcon } from "@heroicons/react/24/outline";

import {
  FAVORITE_ERROR_MESSAGE,
  useFavoriteToggle,
} from "../hooks/useFavorites";
import { useLocations, Location } from "../hooks/useLocations";
import { FavoriteStarIcon } from "./FavoriteStarIcon";
import { SessionContext } from "./SessionProvider";

function classNames(...classes) {
  return classes.filter(Boolean).join(" ");
}

const FavoriteStar = ({
  location,
  onToggled,
}: {
  location: Location;
  onToggled: (succeeded: boolean) => void;
}) => {
  const { isFavorite, isDisabled, toggle } = useFavoriteToggle(location.id);

  return (
    <button
      type="button"
      className="shrink-0 p-2 rounded-md disabled:opacity-50 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
      aria-label={
        isFavorite
          ? `Remove ${location.name} from favorites`
          : `Add ${location.name} to favorites`
      }
      disabled={isDisabled}
      onClick={async () => onToggled(await toggle())}
    >
      <FavoriteStarIcon
        isFavorite={isFavorite}
        outlineClassName="text-gray-400 hover:text-gray-300"
      />
    </button>
  );
};

export const LocationNav = ({ variant }: { variant: "mobile" | "desktop" }) => {
  const { locations = [] } = useLocations();
  const { locationSlug } = useContext(SessionContext);
  const [toggleFailed, setToggleFailed] = useState(false);

  return (
    <>
      {toggleFailed && (
        <p role="alert" className="px-2 py-2 text-sm text-red-300">
          {FAVORITE_ERROR_MESSAGE}
        </p>
      )}
      {locations.map((location) => {
        const isSelected = location.slug === locationSlug;

        return (
          <div
            key={location.id}
            className={classNames(
              isSelected
                ? "bg-gray-900 text-white"
                : "text-gray-300 hover:bg-gray-700 hover:text-white",
              variant === "mobile" ? "text-base" : "text-sm",
              "group flex items-center font-medium rounded-md"
            )}
          >
            <Link
              href={`/locations/${location.slug}`}
              className="flex flex-1 items-center min-w-0 px-2 py-2"
            >
              <MapPinIcon
                className={classNames(
                  isSelected
                    ? "text-red-500"
                    : "text-gray-400 group-hover:text-gray-300",
                  variant === "mobile" ? "mr-4" : "mr-3",
                  "shrink-0 h-6 w-6"
                )}
                aria-hidden="true"
              />
              {location.name}
            </Link>
            <FavoriteStar
              location={location}
              onToggled={(succeeded) => setToggleFailed(!succeeded)}
            />
          </div>
        );
      })}
    </>
  );
};

export default LocationNav;
