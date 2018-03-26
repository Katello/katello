import { foremanTasksApi as api } from '../../services/api';
import { propsToSnakeCase } from '../../services/index';

import {
  GET_TASK_REQUEST,
  GET_TASK_SUCCESS,
  GET_TASK_FAILURE,
  TASK_BULK_SEARCH_REQUEST,
  TASK_BULK_SEARCH_SUCCESS,
  TASK_BULK_SEARCH_FAILURE,
} from './TaskConstants';

export const bulkSearch = (extendedParams = {}) => (dispatch) => {
  const onBulkSearchSuccess = ({ data }) => dispatch({
    type: TASK_BULK_SEARCH_SUCCESS,
    response: data,
  });

  const onBulkSearchFailure = result => dispatch({
    type: TASK_BULK_SEARCH_FAILURE,
    result,
  });

  dispatch({ type: TASK_BULK_SEARCH_REQUEST });

  const params = {
    searches: [{ ...propsToSnakeCase(extendedParams) }],
  };

  return api
    .post('/tasks/bulk_search', params)
    .then(onBulkSearchSuccess)
    .catch(onBulkSearchFailure);
};

export const loadTask = (taskId, extendedParams = {}) => (dispatch) => {
  dispatch({ type: GET_TASK_REQUEST });

  const params = {
    ...propsToSnakeCase(extendedParams),
  };

  return api
    .get(`/tasks/${taskId}`, {}, params)
    .then(({ data }) => dispatch({
      type: GET_TASK_SUCCESS,
      response: data,
    }))
    .catch(result => dispatch({
      type: GET_TASK_FAILURE,
      result,
    }));
};

export const pollBulkSearch = (extendedParams = {}, interval) => (dispatch) => {
  const triggerPolling = () => {
    setTimeout(() => dispatch(pollBulkSearch(extendedParams, interval)), interval);
  };

  return dispatch(bulkSearch(extendedParams)).then(triggerPolling);
};

export const pollTaskUntilDone = (taskId, extendedParams = {}, interval) =>
  dispatch => new Promise((resolve) => {
    const pollUntilDone = (task) => {
      if (task.pending !== false) {
        setTimeout(() => dispatch(loadTask(taskId, extendedParams))
          .then(({ response }) => pollUntilDone(response)), interval);
      } else {
        resolve(task);
      }
    };

    pollUntilDone({ pending: true });
  });
