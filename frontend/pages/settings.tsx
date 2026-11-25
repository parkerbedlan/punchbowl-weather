import { useContext, useEffect } from "react";

import { SessionContext } from "../components/SessionProvider";
import {
  TEMPERATURE_UNIT_SYMBOLS,
  TemperatureUnit,
  useTemperatureUnit,
} from "../hooks/useTemperatureUnit";

const TEMPERATURE_UNIT_NAMES: Record<TemperatureUnit, string> = {
  fahrenheit: "Fahrenheit",
  celsius: "Celsius",
};

export default function SettingsPage() {
  const { setLocationSlug } = useContext(SessionContext);
  const { unit, setUnit } = useTemperatureUnit();

  useEffect(() => {
    setLocationSlug(null);
  }, []);

  return (
    <div className="space-y-6">
      <h1 className="text-center text-4xl font-semibold antialiased tracking-tight">
        Settings
      </h1>
      <section className="mx-auto max-w-md space-y-3 rounded-md bg-white p-4 shadow-lg">
        <h2
          id="temperature-unit-label"
          className="text-lg font-semibold tracking-tight"
        >
          Temperature unit
        </h2>
        <div
          role="radiogroup"
          aria-labelledby="temperature-unit-label"
          className="grid grid-cols-2 gap-1 rounded-md bg-gray-100 p-1"
        >
          {Object.entries(TEMPERATURE_UNIT_NAMES).map(([value, name]) => (
            <label
              key={value}
              className="cursor-pointer rounded-md px-3 py-2 text-center text-sm font-medium text-gray-700 has-checked:bg-white has-checked:text-gray-900 has-checked:shadow has-focus-visible:ring-2 has-focus-visible:ring-indigo-500"
            >
              <input
                type="radio"
                name="temperature-unit"
                className="sr-only"
                value={value}
                checked={unit === value}
                onChange={() => setUnit(value as TemperatureUnit)}
              />
              {name} ({TEMPERATURE_UNIT_SYMBOLS[value]})
            </label>
          ))}
        </div>
      </section>
    </div>
  );
}
