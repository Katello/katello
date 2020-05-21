import { addToast } from 'foremanReact/redux/actions/toasts';
import { propsToSnakeCase } from 'foremanReact/common/helpers';
import { get } from 'foremanReact/redux/API';
import { stopInterval, withInterval } from 'foremanReact/redux/middlewares/IntervalMiddleware';
import { foremanTasksApi } from '../../services/api';
import { bulkSearchKey, pollTaskKey, taskFinishedToast } from './helpers';

const finishedTasks = {};

export const toastTaskFinished = task => async (dispatch) => {
  if (task.id) {
    // Keep track of tasks we've already notified about to prevent duplicate toasts from appearing
    if (finishedTasks[task.id]) return;
    finishedTasks[task.id] = true;
  }
  dispatch(addToast(taskFinishedToast(task)));
};

const taskBulkSearchParams = params => ({
  search: Object.entries(propsToSnakeCase(params))
    .map((item) => {
      if (item[0] === 'action') {
        return `${item[0]}~${item[1]}`;
      }
      return `${item[0]}=${item[1]}`;
    })
    .join(' and '),
});

const getTasks = (key, params = {}) => get({
  key,
  url: `${foremanTasksApi.baseApiPath}/tasks`,
  params: taskBulkSearchParams(params),
});

export const startPollingTasks = (key, taskSearchParams = {}) =>
  withInterval(getTasks(bulkSearchKey(key), taskSearchParams));

export const stopPollingTasks = key => stopInterval(bulkSearchKey(key));

const getTask = (key, task) => get({
  key,
  url: `${foremanTasksApi.baseApiPath}/tasks/${task.id}`,
});

export const startPollingTask = (key, task) =>
  withInterval(getTask(pollTaskKey(key), task));

export const stopPollingTask = key => stopInterval(pollTaskKey(key));
