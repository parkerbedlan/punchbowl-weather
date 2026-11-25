import { StarIcon as StarOutlineIcon } from "@heroicons/react/24/outline";
import { StarIcon as StarSolidIcon } from "@heroicons/react/24/solid";

export const FavoriteStarIcon = ({
  isFavorite,
  outlineClassName,
}: {
  isFavorite: boolean;
  outlineClassName: string;
}) => {
  const StarIcon = isFavorite ? StarSolidIcon : StarOutlineIcon;

  return (
    <StarIcon
      className={`shrink-0 h-6 w-6 ${
        isFavorite ? "text-amber-400" : outlineClassName
      }`}
      aria-hidden="true"
    />
  );
};

export default FavoriteStarIcon;
