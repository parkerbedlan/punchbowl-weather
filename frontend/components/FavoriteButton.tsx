import { useState } from "react";

import { FAVORITE_ERROR_MESSAGE, useFavoriteToggle } from "../hooks/useFavorites";
import { Location } from "../hooks/useLocations";
import { FavoriteStarIcon } from "./FavoriteStarIcon";

export default function FavoriteButton({ location }: { location: Location }) {
  const { isFavorite, isDisabled, toggle } = useFavoriteToggle(location.id);
  const [toggleFailed, setToggleFailed] = useState(false);

  const handleToggleFavorite = async () => setToggleFailed(!(await toggle()));

  return (
    <div className="flex flex-col items-center space-y-2">
      <button
        type="button"
        className="inline-flex items-center gap-2 px-4 py-2 font-semibold text-sm bg-sky-500 text-white rounded-none disabled:opacity-50"
        disabled={isDisabled}
        onClick={handleToggleFavorite}
      >
        <FavoriteStarIcon isFavorite={isFavorite} outlineClassName="text-white" />
        {isFavorite ? 'Remove from' : 'Add to'} favorites
      </button>
      {toggleFailed && (
        <p role="alert" className="text-sm text-red-600">
          {FAVORITE_ERROR_MESSAGE}
        </p>
      )}
    </div>
  );
};
