export const withInterval = (action, interval = 1000) => ({
  ...action,
  interval,
});

export const stopInterval = key => ({
  type: 'STOP_INTERVAL',
  key,
});

export default stopInterval;
