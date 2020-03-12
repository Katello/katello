import { propsToSnakeCase } from 'foremanReact/common/helpers';

import { foremanTasksApi as api } from '../../services/api';
import {
  GET_TASK_REQUEST,
  GET_TASK_SUCCESS,
  GET_TASK_FAILURE,
  TASK_BULK_SEARCH_REQUEST,
  TASK_BULK_SEARCH_SUCCESS,
  TASK_BULK_SEARCH_FAILURE,
  RESET_TASKS,
} from './TaskConstants';

export const bulkSearch = (extendedParams = {}) => async (dispatch) => {
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

  dispatch({ type: TASK_BULK_SEARCH_REQUEST });

  try {
    const { data } = await api.get('/tasks', {}, params);
    return dispatch({
      type: TASK_BULK_SEARCH_SUCCESS,
      response: data,
    });
  } catch (error) {
    return dispatch({
      type: TASK_BULK_SEARCH_FAILURE,
      result: error,
    });
  }
};

export const resetTasks = () => (dispatch) => {
  dispatch({
    type: RESET_TASKS,
  });
};

export const loadTask = (taskId, extendedParams = {}) => async (dispatch) => {
  dispatch({ type: GET_TASK_REQUEST });

  const params = {
    ...propsToSnakeCase(extendedParams),
  };

  try {
    const { data } = await api.get(`/tasks/${taskId}`, {}, params);
    return dispatch({
      type: GET_TASK_SUCCESS,
      response: data,
    });
  } catch (error) {
    return dispatch({
      type: GET_TASK_FAILURE,
      result: error,
    });
  }
};

const isUnauthorized = (action = {}) => (action.result
    && action.result
    && action.result.response
    && action.result.response.status === 401);


export const pollBulkSearch = (extendedParams = {}, interval, orgId) =>
  async (dispatch, getState) => {
    const triggerPolling = (action) => {
      const { id } = getState().katello.organization;
      if (!isUnauthorized(action)) {
        if (id === orgId) {
          setTimeout(() => dispatch(pollBulkSearch(extendedParams, interval, orgId)), interval);
        }
      }
    };
    const { id } = getState().katello.organization;
    if (id === orgId) {
      const dispatchedAction = await dispatch(await bulkSearch(extendedParams));
      triggerPolling(dispatchedAction);
      return dispatchedAction;
    }

    return dispatch({ type: 'POLLING_IS_SKIPPED' });
  };

export const pollTaskUntilDone = (taskId, extendedParams = {}, interval, orgId) =>
  (dispatch, getState) => new Promise((resolve, reject) => {
    const pollUntilDone = (action) => {
      const { id } = getState().katello.organization;

      if (isUnauthorized(action) || id !== orgId) {
        reject(action.result);
      } else if (action.response && action.response.pending) {
        // eslint-disable-next-line promise/prefer-await-to-then
        setTimeout(() => dispatch(loadTask(taskId, extendedParams)).then(pollUntilDone), interval);
      } else {
        resolve(action.response);
      }
    };
    // eslint-disable-next-line promise/prefer-await-to-then
    return dispatch(loadTask(taskId, extendedParams)).then(pollUntilDone);
  });
