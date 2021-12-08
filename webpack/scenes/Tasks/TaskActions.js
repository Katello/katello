import { addToast } from 'foremanReact/redux/actions/toasts';
import { propsToSnakeCase } from 'foremanReact/common/helpers';
import { get } from 'foremanReact/redux/API';
import { stopInterval, withInterval } from 'foremanReact/redux/middlewares/IntervalMiddleware';
import { foremanTasksApi } from '../../services/api';
import { bulkSearchKey, pollTaskKey, taskFinishedToast } from './helpers';

export const toastTaskFinished = task => async (dispatch) => {
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

const getTask = (key, task, handleSuccess) => get({
  key,
  url: `${foremanTasksApi.baseApiPath}/tasks/${task.id}`,
  handleSuccess,
});

export const startPollingTask = (key, task, handleSuccess) =>
  withInterval(getTask(pollTaskKey(key), task, handleSuccess));

export const stopPollingTask = key => stopInterval(pollTaskKey(key));
