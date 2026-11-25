import Link from "next/link";

import { LocationFavoriteCounts } from "../hooks/useLocationFavoriteCounts";
import { Sparkline } from "./Sparkline";

const Change = ({ counts }: { counts: Array<number> }) => {
  const change = counts[counts.length - 1] - counts[0];

  if (change > 0) return <span className="text-green-700">+{change}</span>;
  if (change < 0) return <span className="text-red-700">−{-change}</span>;

  return <span className="text-gray-500">0</span>;
};

export const FavoriteCountsTable = ({
  days,
  locations,
}: {
  days: Array<string>;
  locations: Array<LocationFavoriteCounts>;
}) => {
  return (
    <div className="overflow-x-auto rounded-md bg-white shadow-lg">
      <table className="min-w-full text-left text-gray-900">
        <thead>
          <tr className="border-b border-gray-200 text-sm text-gray-500">
            <th scope="col" className="px-3 py-3 sm:px-4 font-medium">
              Location
            </th>
            <th scope="col" className="px-3 py-3 sm:px-4 text-right font-medium">
              Favorites now
            </th>
            <th
              scope="col"
              className="hidden px-3 py-3 text-right font-medium sm:table-cell sm:px-4"
            >
              Change in {days.length} days
            </th>
            <th scope="col" className="px-3 py-3 sm:px-4 font-medium">
              Last {days.length} days
            </th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-100">
          {locations.map((location) => (
            <tr key={location.id}>
              <th scope="row" className="px-3 py-3 sm:px-4 font-medium">
                <Link
                  href={`/locations/${location.slug}`}
                  className="hover:underline"
                >
                  {location.name}
                </Link>
              </th>
              <td className="px-3 py-3 sm:px-4 text-right font-semibold tabular-nums">
                {location.counts[location.counts.length - 1]}
              </td>
              <td className="hidden px-3 py-3 text-right font-medium tabular-nums sm:table-cell sm:px-4">
                <Change counts={location.counts} />
              </td>
              <td className="px-3 py-3 sm:px-4">
                <Sparkline
                  name={location.name}
                  days={days}
                  counts={location.counts}
                />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default FavoriteCountsTable;
