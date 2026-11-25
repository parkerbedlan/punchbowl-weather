import { ComponentType, SVGProps } from "react";
import Link from "next/link";
import { useRouter } from "next/router";
import { ChartBarIcon, Cog6ToothIcon } from "@heroicons/react/24/outline";

import { useCurrentUser } from "../hooks/useCurrentUser";

type Variant = "mobile" | "desktop";

const PageNavLink = ({
  href,
  label,
  Icon,
  variant,
}: {
  href: string;
  label: string;
  Icon: ComponentType<SVGProps<SVGSVGElement>>;
  variant: Variant;
}) => {
  const isSelected = useRouter().pathname === href;

  return (
    <Link
      href={href}
      className={`group flex items-center px-2 py-2 font-medium rounded-md ${
        variant === "mobile" ? "text-base" : "text-sm"
      } ${
        isSelected
          ? "bg-gray-900 text-white"
          : "text-gray-300 hover:bg-gray-700 hover:text-white"
      }`}
    >
      <Icon
        className={`shrink-0 h-6 w-6 ${variant === "mobile" ? "mr-4" : "mr-3"} ${
          isSelected ? "text-white" : "text-gray-400 group-hover:text-gray-300"
        }`}
        aria-hidden="true"
      />
      {label}
    </Link>
  );
};

export const PageNav = ({ variant }: { variant: Variant }) => {
  const { isAdmin } = useCurrentUser();

  return (
    <div className="mb-4 space-y-1 border-b border-gray-700 pb-4">
      {isAdmin && (
        <PageNavLink
          href="/admin"
          label="Admin dashboard"
          Icon={ChartBarIcon}
          variant={variant}
        />
      )}
      <PageNavLink
        href="/settings"
        label="Settings"
        Icon={Cog6ToothIcon}
        variant={variant}
      />
    </div>
  );
};

export default PageNav;
