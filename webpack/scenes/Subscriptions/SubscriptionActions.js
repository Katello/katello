import { API_OPERATIONS, get, put, APIActions } from 'foremanReact/redux/API';
import { propsToSnakeCase } from 'foremanReact/common/helpers';
import api, { orgId } from '../../services/api';
import { getResponseErrorMsgs } from '../../utils/helpers.js';

import {
  SUBSCRIPTIONS,
  SUBSCRIPTIONS_QUANTITIES_KEY,
  UPDATE_QUANTITY_KEY,
  DELETE_SUBSCRIPTIONS_KEY,
  BLOCKING_FOREMAN_TASK_TYPES,
} from './SubscriptionConstants';
import {
  startPollingTask,
  stopPollingTask,
  startPollingTasks,
  stopPollingTasks,
  toastTaskFinished,
  clearPollTaskData,
} from '../Tasks/TaskActions';
import pingUpstreamSubscriptions from './UpstreamSubscriptions/UpstreamSubscriptionsActions';
import { selectIsPollingTasks, selectIsPollingTask } from '../Tasks/TaskSelectors';
import { bulkSearchKey } from '../Tasks/helpers';

const quantitiesErrorToast = (error) => {
  const messages = getResponseErrorMsgs({
    ...error.response,
    actionType: SUBSCRIPTIONS_QUANTITIES_KEY,
  });
  return Array.isArray(messages) ? messages.join(', ') : messages;
};

export const createSubscriptionParams = (extendedParams = {}) => ({
  ...{
    organization_id: orgId(),
    include_permissions: true,
  },
  ...propsToSnakeCase(extendedParams),
});

export const loadAvailableQuantities = (extendedParams = {}, handleSuccess, handleError) => get({
  type: API_OPERATIONS.GET,
  key: SUBSCRIPTIONS_QUANTITIES_KEY,
  url: api.getApiUrl(`/organizations/${orgId()}/upstream_subscriptions`),
  params: propsToSnakeCase(extendedParams),
  handleSuccess,
  handleError,
  errorToast: quantitiesErrorToast,
});

export const cancelPollTasks = () => (dispatch, getState) => {
  if (selectIsPollingTasks(getState(), SUBSCRIPTIONS)) {
    dispatch(stopPollingTasks(SUBSCRIPTIONS));
  }
};

// Idempotent: do not stop/restart an existing bulk-search interval (restarting
// fires an immediate /foreman_tasks/api/tasks request every time).
export const pollTasks = () => (dispatch, getState) => {
  if (selectIsPollingTasks(getState(), SUBSCRIPTIONS)) {
    return undefined;
  }
  // Clear stale bulk-search payload so empty results from a prior visit cannot
  // cancel this session before the first fresh response arrives (e.g. after
  // redirecting from Add Subscriptions while a bind-entitlements task is pending).
  dispatch({
    type: `${bulkSearchKey(SUBSCRIPTIONS)}_UPDATE`,
    key: bulkSearchKey(SUBSCRIPTIONS),
    payload: {},
  });
  return dispatch(startPollingTasks(SUBSCRIPTIONS, {
    organization_id: orgId(),
    result: 'pending',
    label: BLOCKING_FOREMAN_TASK_TYPES.join(' or '),
  }));
};

export const handleFinishedTask = (task, refreshSubscriptions) =>
  (dispatch) => {
    dispatch(stopPollingTask(SUBSCRIPTIONS));
    dispatch(clearPollTaskData(SUBSCRIPTIONS));
    dispatch(toastTaskFinished(task));
    // Clear stale bulk-search payload so it cannot re-adopt this task, then
    // resume watching for a *new* pending task.
    dispatch({
      type: `${bulkSearchKey(SUBSCRIPTIONS)}_UPDATE`,
      key: bulkSearchKey(SUBSCRIPTIONS),
      payload: {},
    });
    dispatch(cancelPollTasks());
    dispatch(pollTasks());
    if (refreshSubscriptions) {
      refreshSubscriptions();
    }
  };

export const handleStartTask = task => (dispatch, getState) => {
  dispatch(cancelPollTasks());
  if (selectIsPollingTask(getState(), SUBSCRIPTIONS)) {
    dispatch(stopPollingTask(SUBSCRIPTIONS));
  }
  dispatch(clearPollTaskData(SUBSCRIPTIONS));
  dispatch(startPollingTask(SUBSCRIPTIONS, task));
};

export const updateQuantity = (quantities = {}, handleSuccess) => put({
  type: API_OPERATIONS.PUT,
  key: UPDATE_QUANTITY_KEY,
  url: api.getApiUrl(`/organizations/${orgId()}/upstream_subscriptions`),
  params: { pools: quantities },
  handleSuccess,
  errorToast: quantitiesErrorToast,
});

// Foreman APIActions.delete does not send a body; pass pool_ids as query params.
export const deleteSubscriptions = (poolIds, handleSuccess) => {
  const query = (poolIds || [])
    .map(id => `pool_ids[]=${encodeURIComponent(id)}`)
    .join('&');

  return APIActions.delete({
    type: API_OPERATIONS.DELETE,
    key: DELETE_SUBSCRIPTIONS_KEY,
    url: api.getApiUrl(`/organizations/${orgId()}/upstream_subscriptions?${query}`),
    handleSuccess,
    errorToast: quantitiesErrorToast,
  });
};
