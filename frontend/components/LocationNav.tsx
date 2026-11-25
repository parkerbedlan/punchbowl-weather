import { useContext, useState } from "react";
import Link from "next/link";
import { MapPinIcon } from "@heroicons/react/24/outline";

import {
  FAVORITE_ERROR_MESSAGE,
  useFavoriteToggle,
  useUserFavorites,
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

const LocationNavItem = ({
  location,
  variant,
  onToggled,
}: {
  location: Location;
  variant: "mobile" | "desktop";
  onToggled: (succeeded: boolean) => void;
}) => {
  const { locationSlug } = useContext(SessionContext);
  const isSelected = location.slug === locationSlug;

  return (
    <div
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
      <FavoriteStar location={location} onToggled={onToggled} />
    </div>
  );
};

const SECTION_LABEL_CLASS_NAME = "px-2 text-xs/6 font-semibold text-gray-400";

export const LocationNav = ({ variant }: { variant: "mobile" | "desktop" }) => {
  const { locations = [] } = useLocations();
  const { favorites, isLoading: areFavoritesLoading } = useUserFavorites();
  const [toggleFailed, setToggleFailed] = useState(false);

  if (areFavoritesLoading) return null;

  const favoriteLocationIds = new Set(
    favorites?.map((favorite) => favorite.location_id)
  );
  const favoriteLocations = locations.filter((location) =>
    favoriteLocationIds.has(location.id)
  );
  const otherLocations = locations.filter(
    (location) => !favoriteLocationIds.has(location.id)
  );
  const locationNavItems = (locationsInSection: Array<Location>) =>
    locationsInSection.map((location) => (
      <LocationNavItem
        key={location.id}
        location={location}
        variant={variant}
        onToggled={(succeeded) => setToggleFailed(!succeeded)}
      />
    ));

  return (
    <>
      {toggleFailed && (
        <p role="alert" className="px-2 py-2 text-sm text-red-300">
          {FAVORITE_ERROR_MESSAGE}
        </p>
      )}
      {favorites && (
        <section className="mb-4 space-y-1 border-b border-gray-700 pb-4">
          <h2 className={SECTION_LABEL_CLASS_NAME}>Your favorites</h2>
          {favoriteLocations.length === 0 && (
            <p className="px-2 py-2 text-sm text-gray-400">
              Select the star next to a location to add it here.
            </p>
          )}
          {locationNavItems(favoriteLocations)}
        </section>
      )}
      <section className="space-y-1">
        <div className="px-2">
          <h2 className="text-xs/6 font-semibold text-gray-400">
            All locations
          </h2>
          <p className="text-xs text-gray-400">
            Use the search bar at the top of the page to add more.
          </p>
        </div>
        {locationNavItems(otherLocations)}
      </section>
    </>
  );
};

export default LocationNav;
