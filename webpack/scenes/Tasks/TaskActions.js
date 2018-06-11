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

const isUnauthorized = action =>
  (action.result && action.result.response && action.result.response.status === 401);

export const pollBulkSearch = (extendedParams = {}, interval) => (dispatch) => {
  const triggerPolling = (action) => {
    if (!isUnauthorized(action)) {
      setTimeout(() => dispatch(pollBulkSearch(extendedParams, interval)), interval);
    }
  };

  return dispatch(bulkSearch(extendedParams)).then(triggerPolling);
};

export const pollTaskUntilDone = (taskId, extendedParams = {}, interval) => dispatch => (
  new Promise((resolve, reject) => {
    const pollUntilDone = (action) => {
      if (isUnauthorized(action)) {
        reject(action.result);
      } else if (action.response.pending !== false) {
        setTimeout(() => dispatch(loadTask(taskId, extendedParams)).then(pollUntilDone), interval);
      } else {
        resolve(action.response);
      }
    };

    return dispatch(loadTask(taskId, extendedParams)).then(pollUntilDone);
  })
);
