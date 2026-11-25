import { useEffect, useState } from "react";

const relativeTimeFormat = new Intl.RelativeTimeFormat("en", {
  style: "narrow",
});

const SECONDS_PER_UNIT: Array<[Intl.RelativeTimeFormatUnit, number]> = [
  ["day", 86_400],
  ["hour", 3_600],
  ["minute", 60],
  ["second", 1],
];

const formatAge = (ageInSeconds: number) => {
  const [unit, secondsPerUnit] =
    SECONDS_PER_UNIT.find(([, seconds]) => ageInSeconds >= seconds) ??
    SECONDS_PER_UNIT[SECONDS_PER_UNIT.length - 1];

  return relativeTimeFormat.format(
    -Math.floor(ageInSeconds / secondsPerUnit),
    unit
  );
};

export const LastUpdated = ({ fetchedAt }: { fetchedAt: string }) => {
  const [now, setNow] = useState(() => Date.now());

  useEffect(() => {
    const timer = setInterval(() => setNow(Date.now()), 1_000);

    return () => clearInterval(timer);
  }, []);

  const ageInSeconds = Math.max(
    0,
    Math.floor((now - Date.parse(fetchedAt)) / 1_000)
  );

  return (
    <div className="text-center text-sm text-gray-600">
      Last updated {formatAge(ageInSeconds)}
    </div>
  );
};

export default LastUpdated;
