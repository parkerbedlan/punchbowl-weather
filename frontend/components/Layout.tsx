import React, { ReactNode, useContext, useMemo } from "react";
import Head from "next/head";
import Link from "next/link";

import { Fragment, useState } from "react";
import {
  Dialog,
  DialogPanel,
  Transition,
  TransitionChild,
} from "@headlessui/react";
import {
  XMarkIcon,
  MapPinIcon,
  Bars3Icon,
  StarIcon,
} from "@heroicons/react/24/outline";
import { useLocations, Location } from "../hooks/useLocations";
import { useUserFavorites } from "../hooks/useFavorites";
import { SessionContext } from "./SessionProvider";

function classNames(...classes) {
  return classes.filter(Boolean).join(" ");
}

const locationPath = ({ slug }: Location) => `/locations/${slug}`;

export const Layout = ({ children }: { children: ReactNode }) => {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const { locations } = useLocations();
  const { locationSlug } = useContext(SessionContext);
  // const { favorites } = useUserFavorites();

  const isSelected = ({ slug }: Location) => slug === locationSlug;

  const favoriteLocationIds = []; // Remove this line and uncomment the section below when you implement favorites.
  // const favoriteLocationIds = useMemo(() => {
  //   return favorites?.map(({ location_id }) => location_id) ?? [];
  // }, [favorites]);

  return (
    <>
      <Head>
        <title>Weather</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <div className="h-screen flex overflow-hidden bg-gray-100">
        <Transition show={sidebarOpen} as={Fragment}>
          <Dialog
            as="div"
            className="fixed inset-0 flex z-40 md:hidden"
            onClose={setSidebarOpen}
          >
            <TransitionChild
              as={Fragment}
              enter="transition-opacity ease-linear duration-300"
              enterFrom="opacity-0"
              enterTo="opacity-100"
              leave="transition-opacity ease-linear duration-300"
              leaveFrom="opacity-100"
              leaveTo="opacity-0"
            >
              <div
                className="fixed inset-0 bg-gray-600/75"
                aria-hidden="true"
              />
            </TransitionChild>
            <TransitionChild
              as={Fragment}
              enter="transition ease-in-out duration-300 transform"
              enterFrom="-translate-x-full"
              enterTo="translate-x-0"
              leave="transition ease-in-out duration-300 transform"
              leaveFrom="translate-x-0"
              leaveTo="-translate-x-full"
            >
              <DialogPanel className="relative flex-1 flex flex-col max-w-xs w-full pt-5 pb-4 bg-gray-800">
                <TransitionChild
                  as={Fragment}
                  enter="ease-in-out duration-300"
                  enterFrom="opacity-0"
                  enterTo="opacity-100"
                  leave="ease-in-out duration-300"
                  leaveFrom="opacity-100"
                  leaveTo="opacity-0"
                >
                  <div className="absolute top-0 right-0 -mr-12 pt-2">
                    <button
                      type="button"
                      className="ml-1 flex items-center justify-center h-10 w-10 rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
                      onClick={() => setSidebarOpen(false)}
                    >
                      <span className="sr-only">Close sidebar</span>
                      <XMarkIcon
                        className="h-6 w-6 text-white"
                        aria-hidden="true"
                      />
                    </button>
                  </div>
                </TransitionChild>
                <div className="shrink-0 flex items-center px-4 text-white text-3xl antialiased font-semibold">
                  <Link href="/">Weather</Link>
                </div>
                <div className="mt-5 flex-1 h-0 overflow-y-auto">
                  <nav className="px-2 space-y-1">
                    {locations && locations.map((location) => (
                      <Link
                        key={"location-link"}
                        href={locationPath(location)}
                        className={classNames(
                          isSelected(location)
                            ? "bg-gray-900 text-white"
                            : "text-gray-300 hover:bg-gray-700 hover:text-white",
                          "group flex items-center px-2 py-2 text-base font-medium rounded-md"
                        )}
                      >
                        <MapPinIcon
                          className={classNames(
                            isSelected(location)
                              ? "text-red-500"
                              : "text-gray-400 group-hover:text-gray-300",
                            "mr-4 shrink-0 h-6 w-6"
                          )}
                          aria-hidden="true"
                        />
                        {location.name}
                        <div className="flex grow justify-end">
                          <StarIcon
                            className={classNames(
                              favoriteLocationIds.includes(location.id) ? "text-red-500" : "text-gray-400",
                              'h-6 w-6'
                            )}
                          />
                        </div>
                      </Link>
                    ))}
                  </nav>
                </div>
              </DialogPanel>
            </TransitionChild>
            <div className="shrink-0 w-14" aria-hidden="true">
              {/* Dummy element to force sidebar to shrink to fit close icon */}
            </div>
          </Dialog>
        </Transition>

        {/* Static sidebar for desktop */}
        <div className="hidden md:flex md:shrink-0">
          <div className="flex flex-col w-64">
            {/* Sidebar component, swap this element with another sidebar if you like */}
            <div className="flex-1 flex flex-col min-h-0">
              <div className="flex items-center h-16 shrink-0 px-4 bg-gray-900 text-white font-semibold text-3xl antialiased">
                <Link href="/">Weather</Link>
              </div>
              <div className="flex-1 flex flex-col overflow-y-auto">
                <nav className="flex-1 px-2 py-4 bg-gray-800 space-y-1">
                  {locations && locations.map((location) => (
                    <Link
                      key={"location.name"}
                      href={locationPath(location)}
                      className={classNames(
                        isSelected(location)
                          ? "bg-gray-900 text-white"
                          : "text-gray-300 hover:bg-gray-700 hover:text-white",
                        "group flex items-center px-2 py-2 text-sm font-medium rounded-md"
                      )}
                    >
                      <MapPinIcon
                        className={classNames(
                          isSelected(location)
                            ? "text-red-500"
                            : "text-gray-400 group-hover:text-gray-300",
                          "mr-3 shrink-0 h-6 w-6"
                        )}
                        aria-hidden="true"
                      />
                      {location.name}
                      <div className="flex grow justify-end">
                        <StarIcon
                          className={classNames(
                            favoriteLocationIds.includes(location) ? "text-red-500" : "text-gray-400",
                            'h-6 w-6'
                          )}
                        />
                      </div>
                    </Link>
                  ))}
                </nav>
              </div>
            </div>
          </div>
        </div>
        <div className="flex flex-col w-0 flex-1 overflow-hidden">
          <div className="relative z-10 shrink-0 flex h-16 bg-white shadow">
            <button
              type="button"
              className="px-4 border-r border-gray-200 text-gray-500 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500 md:hidden"
              onClick={() => setSidebarOpen(true)}
            >
              <span className="sr-only">Open sidebar</span>
              <Bars3Icon className="h-6 w-6" aria-hidden="true" />
            </button>
          </div>

          <main className="flex-1 relative overflow-y-auto focus:outline-none">
            <div className="py-6">
              <div className="max-w-7xl mx-auto px-4 sm:px-6 md:px-8 py-2">
                {children}
              </div>
            </div>
          </main>
        </div>
      </div>
    </>
  );
};

export default Layout;
