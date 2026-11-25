import { useContext, useEffect } from "react";

import { FavoriteCountsTable } from "../../components/FavoriteCountsTable";
import { SessionContext } from "../../components/SessionProvider";
import { useCurrentUser } from "../../hooks/useCurrentUser";
import {
  FAVORITE_COUNTS_ERROR_MESSAGE,
  useLocationFavoriteCounts,
} from "../../hooks/useLocationFavoriteCounts";

const Notice = ({ message }: { message: string }) => (
  <p role="alert" className="text-center text-gray-700">
    {message}
  </p>
);

export default function AdminPage() {
  const { setLocationSlug } = useContext(SessionContext);
  const { isAdmin, isLoading, isError: isCurrentUserError } = useCurrentUser();
  const { days, locations, isError } = useLocationFavoriteCounts(isAdmin);

  useEffect(() => {
    setLocationSlug(null);
  }, []);

  if (isLoading) return null;
  if (isCurrentUserError || isError) {
    return <Notice message={FAVORITE_COUNTS_ERROR_MESSAGE} />;
  }
  if (!isAdmin) return <Notice message="You don't have access to this page." />;

  return (
    <div className="space-y-6">
      <h1 className="text-center text-4xl font-semibold antialiased tracking-tight">
        Admin dashboard
      </h1>
      <section className="space-y-3">
        <div>
          <h2 className="text-xl font-semibold tracking-tight">
            Favorites by location
          </h2>
          <p className="text-sm text-gray-600">
            The number of users who had each location as a favorite at the end
            of each day. Days are in UTC.
          </p>
        </div>
        {locations?.length === 0 && (
          <p className="text-gray-700">
            No location had a favorite in the last 30 days.
          </p>
        )}
        {locations?.length > 0 && (
          <FavoriteCountsTable days={days} locations={locations} />
        )}
      </section>
    </div>
  );
}
