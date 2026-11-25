import Link from "next/link";
import { useRouter } from "next/router";
import { ChartBarIcon } from "@heroicons/react/24/outline";

import { useCurrentUser } from "../hooks/useCurrentUser";

export const AdminNav = ({ variant }: { variant: "mobile" | "desktop" }) => {
  const { isAdmin } = useCurrentUser();
  const isSelected = useRouter().pathname === "/admin";

  if (!isAdmin) return null;

  return (
    <div className="mt-4 border-t border-gray-700 pt-4">
      <Link
        href="/admin"
        className={`group flex items-center px-2 py-2 font-medium rounded-md ${
          variant === "mobile" ? "text-base" : "text-sm"
        } ${
          isSelected
            ? "bg-gray-900 text-white"
            : "text-gray-300 hover:bg-gray-700 hover:text-white"
        }`}
      >
        <ChartBarIcon
          className={`shrink-0 h-6 w-6 ${variant === "mobile" ? "mr-4" : "mr-3"} ${
            isSelected ? "text-white" : "text-gray-400 group-hover:text-gray-300"
          }`}
          aria-hidden="true"
        />
        Admin dashboard
      </Link>
    </div>
  );
};

export default AdminNav;
