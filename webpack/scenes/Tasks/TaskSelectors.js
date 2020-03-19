import { selectDoesIntervalExist } from 'foremanReact/redux/middlewares/IntervalMiddleware/IntervalSelectors';
import { bulkSearchKey, pollTaskKey } from './helpers';

export const selectIsPollingTask = (state, key) => selectDoesIntervalExist(state, pollTaskKey(key));

export const selectIsPollingTasks = (state, key) =>
  selectDoesIntervalExist(state, bulkSearchKey(key));
