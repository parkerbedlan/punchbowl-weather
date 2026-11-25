import { KeyboardEvent, PointerEvent, useState } from "react";

import { formatDay } from "../hooks/useLocationFavoriteCounts";

const WIDTH = 160;
const HEIGHT = 36;
const PADDING = 5;
const LINE_COLOR = "#2a78d6";

export const Sparkline = ({
  name,
  days,
  counts,
}: {
  name: string;
  days: Array<string>;
  counts: Array<number>;
}) => {
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);

  const lastIndex = counts.length - 1;
  const highestCount = Math.max(...counts, 1);
  const stepWidth = (WIDTH - 2 * PADDING) / Math.max(lastIndex, 1);
  const x = (index: number) => PADDING + index * stepWidth;
  const y = (count: number) =>
    HEIGHT - PADDING - (count / highestCount) * (HEIGHT - 2 * PADDING);
  const markedIndex = selectedIndex ?? lastIndex;

  const selectNearestDay = (event: PointerEvent<SVGSVGElement>) => {
    const box = event.currentTarget.getBoundingClientRect();
    const pointerX = ((event.clientX - box.left) / box.width) * WIDTH;
    const index = Math.round((pointerX - PADDING) / stepWidth);

    setSelectedIndex(Math.min(Math.max(index, 0), lastIndex));
  };

  const selectNextDay = (event: KeyboardEvent<SVGSVGElement>) => {
    const step = { ArrowLeft: -1, ArrowRight: 1 }[event.key];
    if (!step) return;

    event.preventDefault();
    setSelectedIndex(Math.min(Math.max(markedIndex + step, 0), lastIndex));
  };

  return (
    <div className="relative inline-block">
      {selectedIndex !== null && (
        <div
          className="absolute bottom-full z-10 mb-1 -translate-x-1/2 whitespace-nowrap rounded bg-gray-900 px-2 py-1 text-xs text-gray-300 pointer-events-none"
          style={{ left: `${(x(selectedIndex) / WIDTH) * 100}%` }}
        >
          <span className="font-semibold text-white">
            {counts[selectedIndex]}
          </span>{" "}
          {formatDay(days[selectedIndex])}
        </div>
      )}
      <svg
        role="img"
        aria-label={`${name}: ${counts[0]} on ${formatDay(days[0])}, ${
          counts[lastIndex]
        } on ${formatDay(days[lastIndex])}. Use the left and right arrow keys to read each day.`}
        tabIndex={0}
        viewBox={`0 0 ${WIDTH} ${HEIGHT}`}
        className="block h-auto w-24 rounded sm:w-40 focus:outline-none focus-visible:ring-2 focus-visible:ring-indigo-500"
        onPointerMove={selectNearestDay}
        onPointerLeave={() => setSelectedIndex(null)}
        onFocus={() => setSelectedIndex(lastIndex)}
        onBlur={() => setSelectedIndex(null)}
        onKeyDown={selectNextDay}
      >
        {selectedIndex !== null && (
          <line
            x1={x(selectedIndex)}
            x2={x(selectedIndex)}
            y1={0}
            y2={HEIGHT}
            stroke="#c3c2b7"
            strokeWidth={1}
          />
        )}
        <polyline
          points={counts.map((count, index) => `${x(index)},${y(count)}`).join(" ")}
          fill="none"
          stroke={LINE_COLOR}
          strokeWidth={2}
          strokeLinejoin="round"
          strokeLinecap="round"
        />
        <circle
          cx={x(markedIndex)}
          cy={y(counts[markedIndex])}
          r={4}
          fill={LINE_COLOR}
          stroke="#ffffff"
          strokeWidth={2}
        />
      </svg>
    </div>
  );
};

export default Sparkline;
