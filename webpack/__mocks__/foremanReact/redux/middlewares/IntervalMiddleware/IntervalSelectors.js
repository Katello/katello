export const selectDoesIntervalExist = (state, key) => {
  const intervals = state.intervals || {};
  return !!intervals[key];
};

export default selectDoesIntervalExist;
