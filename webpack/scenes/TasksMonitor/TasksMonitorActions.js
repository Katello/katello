import { foremanTasksApi as api } from '../../services/api';
import { propsToSnakeCase } from '../../services/index';

import {
  TASKS_MONITOR_STARTED,
  TASKS_MONITOR_STOPPED,
  TASKS_MONITOR_SUCCESS,
  TASKS_MONITOR_FAILED,
  TASKS_MONITOR_ALREADY_MONITORED,
} from './TasksMonitorConstants';
import { selectMonitor, selectIsMonitorActive } from './TasksMonitorSelectors';

const isUnauthorizedResponse = apiResponse => apiResponse.status === 401;

const performBulkSearch = (params = {}) => {
  const apiParams = {
    searches: [{ ...propsToSnakeCase(params) }],
  };

  return api.post('/tasks/bulk_search', apiParams);
};

export const stopMonitoringTasks = id => (dispatch, getState) => {
  const { intervalId } = selectMonitor(getState(), id);

  clearInterval(intervalId);

  dispatch({
    type: TASKS_MONITOR_STOPPED,
    payload: { id, intervalId },
  });
};

export const runMonitorLifecycle = id => async (dispatch, getState) => {
  try {
    const { params } = selectMonitor(getState(), id);
    const response = await performBulkSearch(params);

    if (isUnauthorizedResponse(response)) {
      dispatch(stopMonitoringTasks(id));
      throw new Error('Unauthorized');
    }

    const tasks = response.data[0].results;

    dispatch({
      type: TASKS_MONITOR_SUCCESS,
      payload: { id, tasks },
    });
  } catch (error) {
    dispatch({
      type: TASKS_MONITOR_FAILED,
      payload: { id, error },
    });
  }
};

export const startMonitoringTasks = ({ id = 'some-uid', interval = 5000, params = {} }) => (
  dispatch,
  getState,
) => {
  if (selectIsMonitorActive(getState(), id)) {
    return dispatch({
      type: TASKS_MONITOR_ALREADY_MONITORED,
      payload: { id, interval, params },
    });
  }

  const intervalId = setInterval(() => dispatch(runMonitorLifecycle(id)), interval);

  dispatch({
    type: TASKS_MONITOR_STARTED,
    payload: {
      id, interval, intervalId, params,
    },
  });

  // run it manually so we don't wait the interval for the first time
  return dispatch(runMonitorLifecycle(id));
};
