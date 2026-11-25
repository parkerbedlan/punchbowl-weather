import {
  CartesianGrid,
  Line,
  LineChart,
  Tooltip,
  TooltipContentProps,
  XAxis,
  YAxis,
} from "recharts";

import {
  LocationFavoriteCounts,
  formatDay,
} from "../hooks/useLocationFavoriteCounts";

const LINE_COLORS = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4"];
const AXIS_TEXT = { fill: "#6b7280", fontSize: 12 };

const LineKey = ({ color }: { color: string }) => (
  <span
    className="inline-block h-0.5 w-4 shrink-0 rounded-full"
    style={{ backgroundColor: color }}
    aria-hidden="true"
  />
);

const DayTooltip = ({ active, payload, label }: TooltipContentProps) => {
  if (!active || !payload?.length) return null;

  const highestCountFirst = [...payload].sort(
    (a, b) => Number(b.value) - Number(a.value)
  );

  return (
    <div className="rounded bg-gray-900 px-3 py-2 text-xs text-gray-300 shadow-lg">
      <div className="mb-1 font-medium text-white">
        {formatDay(String(label))}
      </div>
      {highestCountFirst.map((line) => (
        <div key={String(line.dataKey)} className="flex items-center gap-2">
          <LineKey color={line.color} />
          <span className="font-semibold tabular-nums text-white">
            {line.value}
          </span>
          <span>{line.name}</span>
        </div>
      ))}
    </div>
  );
};

export const FavoriteCountsChart = ({
  days,
  locations,
}: {
  days: Array<string>;
  locations: Array<LocationFavoriteCounts>;
}) => {
  const chartedLocations = locations.slice(0, LINE_COLORS.length);
  const colorByLocationId = new Map(
    [...chartedLocations]
      .sort((a, b) => a.id - b.id)
      .map((location, index) => [location.id, LINE_COLORS[index]])
  );
  const countsByDay = days.map((day, index) => ({
    day,
    ...Object.fromEntries(
      chartedLocations.map((location) => [location.id, location.counts[index]])
    ),
  }));

  return (
    <figure className="space-y-3 rounded-md bg-white p-4 shadow-lg">
      <figcaption className="text-sm font-medium text-gray-900">
        {locations.length > chartedLocations.length
          ? `The ${chartedLocations.length} locations with the most favorites now`
          : "Each location with a favorite in this time"}
      </figcaption>
      <ul className="flex flex-wrap gap-x-4 gap-y-1 text-sm text-gray-700">
        {chartedLocations.map((location) => (
          <li key={location.id} className="flex items-center gap-2">
            <LineKey color={colorByLocationId.get(location.id)} />
            {location.name}
          </li>
        ))}
      </ul>
      <LineChart
        responsive
        data={countsByDay}
        style={{ width: "100%", height: 288 }}
        margin={{ top: 8, right: 12, bottom: 0, left: 0 }}
      >
        <CartesianGrid vertical={false} stroke="#e5e7eb" />
        <XAxis
          dataKey="day"
          tickFormatter={formatDay}
          tick={AXIS_TEXT}
          tickLine={false}
          axisLine={{ stroke: "#d1d5db" }}
          minTickGap={32}
        />
        <YAxis
          allowDecimals={false}
          width={32}
          tick={AXIS_TEXT}
          tickLine={false}
          axisLine={false}
        />
        <Tooltip
          content={DayTooltip}
          cursor={{ stroke: "#9ca3af", strokeWidth: 1 }}
          isAnimationActive={false}
        />
        {chartedLocations.map((location) => (
          <Line
            key={location.id}
            dataKey={String(location.id)}
            name={location.name}
            type="linear"
            stroke={colorByLocationId.get(location.id)}
            strokeWidth={2}
            dot={false}
            activeDot={{ r: 4, stroke: "#ffffff", strokeWidth: 2 }}
            isAnimationActive={false}
          />
        ))}
      </LineChart>
    </figure>
  );
};

export default FavoriteCountsChart;
