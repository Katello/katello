import { selectDoesIntervalExist } from 'foremanReact/redux/middlewares/IntervalMiddleware/IntervalSelectors';
import { bulkSearchKey, pollTaskKey } from './helpers';

export const selectIsPollingTask = (state, key) => selectDoesIntervalExist(state, pollTaskKey(key));

export const selectIsPollingTaskComplete = (state, key) => {
  const taskKey = pollTaskKey(key);
  const { response } = state?.API[taskKey] || {};
  if (response) {
    const { progress, pending, result } = response;
    return progress === 1 && pending === false &&
      (result === 'success' || result === 'error');
  }
  return false;
};

export const selectIsPollingTasks = (state, key) =>
  selectDoesIntervalExist(state, bulkSearchKey(key));
