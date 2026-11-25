import { useSyncExternalStore } from "react";

export type TemperatureUnit = "fahrenheit" | "celsius";

export const TEMPERATURE_UNIT_SYMBOLS: Record<TemperatureUnit, string> = {
  fahrenheit: "°F",
  celsius: "°C",
};

const STORAGE_KEY = "temperatureUnit";
const CHANGE_EVENT = "temperatureunitchange";

const subscribe = (onChange: () => void) => {
  window.addEventListener("storage", onChange);
  window.addEventListener(CHANGE_EVENT, onChange);

  return () => {
    window.removeEventListener("storage", onChange);
    window.removeEventListener(CHANGE_EVENT, onChange);
  };
};

const storedUnit = (): TemperatureUnit =>
  window.localStorage.getItem(STORAGE_KEY) === "celsius"
    ? "celsius"
    : "fahrenheit";

const unitBeforeHydration = (): TemperatureUnit => "fahrenheit";

export const useTemperatureUnit = () => {
  const unit = useSyncExternalStore(subscribe, storedUnit, unitBeforeHydration);

  const setUnit = (selectedUnit: TemperatureUnit) => {
    window.localStorage.setItem(STORAGE_KEY, selectedUnit);
    window.dispatchEvent(new Event(CHANGE_EVENT));
  };

  return { unit, setUnit };
};

export const formatTemperature = (
  degreesFahrenheit: number,
  unit: TemperatureUnit
) => {
  const degrees =
    unit === "celsius" ? ((degreesFahrenheit - 32) * 5) / 9 : degreesFahrenheit;

  return `${Math.round(degrees)}${TEMPERATURE_UNIT_SYMBOLS[unit]}`;
};

export default useTemperatureUnit;
