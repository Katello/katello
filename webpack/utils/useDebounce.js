import { useEffect, useState } from 'react';

export default (value, delay = 500) => {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    // If the value is undefined or "" we want any logic to update immediately
    // as we wouldn't be waiting on the user to finish typing any longer.
    if (!value) {
      setDebouncedValue(value);
      return () => undefined;
    }
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => {
      clearTimeout(timer);
    };
  }, [value, delay]);

  return debouncedValue;
};
