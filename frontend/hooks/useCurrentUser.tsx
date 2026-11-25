import useSWR from "swr";

type CurrentUser = {
  id: number;
  role: "member" | "admin";
};

const CURRENT_USER_URL = `${process.env.NEXT_PUBLIC_API_BASE}/api/current_user`;

const fetcher = async (path: string): Promise<CurrentUser> => {
  const response = await fetch(path);
  if (!response.ok) {
    throw new Error(`The current user request failed with HTTP ${response.status}`);
  }

  return response.json();
};

export const useCurrentUser = () => {
  const { data, error } = useSWR<CurrentUser, Error>(CURRENT_USER_URL, fetcher);

  return {
    isAdmin: data?.role === "admin",
    isLoading: !data && !error,
    isError: !data && Boolean(error),
  };
};

export default useCurrentUser;
