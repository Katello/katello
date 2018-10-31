import { foremanTasksApi as api } from '../../services/api';
import { propsToSnakeCase } from '../../services/index';

import {
  GET_TASK_REQUEST,
  GET_TASK_SUCCESS,
  GET_TASK_FAILURE,
  TASK_BULK_SEARCH_REQUEST,
  TASK_BULK_SEARCH_SUCCESS,
  TASK_BULK_SEARCH_FAILURE,
  RESET_TASKS,
} from './TaskConstants';

export const bulkSearch = (extendedParams = {}) => (dispatch) => {
  const params = {
    search: Object.entries(propsToSnakeCase(extendedParams))
      .map((item) => {
        if (item[0] === 'action') {
          return `${item[0]}~${item[1]}`;
        }
        return `${item[0]}=${item[1]}`;
      })
      .join(' and '),
  };


  const onBulkSearchSuccess = ({ data }) => dispatch({
    type: TASK_BULK_SEARCH_SUCCESS,
    response: data,
  });

  const onBulkSearchFailure = result => dispatch({
    type: TASK_BULK_SEARCH_FAILURE,
    result,
  });

  dispatch({ type: TASK_BULK_SEARCH_REQUEST });
  return api
    .get('/tasks', {}, params)
    .then(onBulkSearchSuccess)
    .catch(onBulkSearchFailure);
};

export const resetTasks = () => (dispatch) => {
  dispatch({
    type: RESET_TASKS,
  });
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

export const pollBulkSearch = (extendedParams = {}, interval, orgId) =>
  (dispatch, getState) => {
    const { currentOrganization: { id } } = getState().layout;
    const triggerPolling = (action) => {
      if (!isUnauthorized(action)) {
        if (id === orgId) {
          setTimeout(() => dispatch(pollBulkSearch(extendedParams, interval, orgId)), interval);
        }
      }
    };
    const { loading } = getState().katello.organization;

    if (id === orgId && !loading) {
      return dispatch(bulkSearch(extendedParams)).then(triggerPolling);
    }

    return dispatch({ type: 'POLLING_IS_SKIPPED' });
  };

export const pollTaskUntilDone = (taskId, extendedParams = {}, interval, orgId) =>
  (dispatch, getState) => new Promise((resolve, reject) => {
    const pollUntilDone = (action) => {
      const { loading } = getState().katello.organization;
      const { currentOrganization: { id } } = getState().layout;

      if (isUnauthorized(action) || id !== orgId || loading) {
        reject(action.result);
      } else if (action.response.pending) {
        setTimeout(() => dispatch(loadTask(taskId, extendedParams)).then(pollUntilDone), interval);
      } else {
        resolve(action.response);
      }
    };

    return dispatch(loadTask(taskId, extendedParams)).then(pollUntilDone);
  });
