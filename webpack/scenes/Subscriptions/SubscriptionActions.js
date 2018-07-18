import api, { orgId } from '../../services/api';
import { apiError } from '../../move_to_foreman/common/helpers';
import { propsToSnakeCase } from '../../services/index';
import { startMonitoringTasks, stopMonitoringTasks, runMonitorLifecycle } from '../TasksMonitor/TasksMonitorActions';
import { selectIsMonitorActive } from '../TasksMonitor/TasksMonitorSelectors';

import {
  SUBSCRIPTIONS_REQUEST,
  SUBSCRIPTIONS_SUCCESS,
  SUBSCRIPTIONS_FAILURE,
  SUBSCRIPTIONS_QUANTITIES_REQUEST,
  SUBSCRIPTIONS_QUANTITIES_SUCCESS,
  SUBSCRIPTIONS_QUANTITIES_FAILURE,
  UPDATE_QUANTITY_REQUEST,
  UPDATE_QUANTITY_SUCCESS,
  UPDATE_QUANTITY_FAILURE,
  DELETE_SUBSCRIPTIONS_REQUEST,
  DELETE_SUBSCRIPTIONS_SUCCESS,
  DELETE_SUBSCRIPTIONS_FAILURE,
  SUBSCRIPTIONS_EXPORT_CSV,
  SUBSCRIPTIONS_OPEN_MANIFEST_MODAL,
  SUBSCRIPTIONS_CLOSE_MANIFEST_MODAL,
  SUBSCRIPTIONS_OPEN_DELETE_MODAL,
  SUBSCRIPTIONS_CLOSE_DELETE_MODAL,
  SUBSCRIPTIONS_DISABLE_DELETE_BUTTON,
  SUBSCRIPTIONS_ENABLE_DELETE_BUTTON,
  SUBSCRIPTIONS_UPDATE_SEARCH_QUERY,
  SUBSCRIPTIONS_START_MONITORING_MANIFEST_TASKS,
  SUBSCRIPTIONS_STOP_MONITORING_MANIFEST_TASKS,
  SUBSCRIPTIONS_RUN_MONITOR_MANIFEST_TASKS_MANUALLY,
  SUBSCRIPTIONS_START_MONITORING_MANIFEST_TASKS_FAILED,
  SUBSCRIPTIONS_BLOCKING_FOREMAN_TASK_TYPES,
  SUBSCRIPTIONS_MONITOR_TASKS_INTERVAL,
  SUBSCRIPTIONS_MONITOR_TASKS_ID,
} from './SubscriptionConstants';
import {
  filterRHSubscriptions,
  selectSubscriptionsQuantitiesFromResponse,
} from './SubscriptionHelpers';

export const runMonitorManifestTasksManually =
  (id = SUBSCRIPTIONS_MONITOR_TASKS_ID) => (dispatch) => {
    dispatch({
      type: SUBSCRIPTIONS_RUN_MONITOR_MANIFEST_TASKS_MANUALLY,
      payload: id,
    });

    return dispatch(runMonitorLifecycle(id));
  };

export const stopMonitoringManifestTasks = (id = SUBSCRIPTIONS_MONITOR_TASKS_ID) => (dispatch) => {
  dispatch({
    type: SUBSCRIPTIONS_STOP_MONITORING_MANIFEST_TASKS,
    payload: id,
  });

  return dispatch(stopMonitoringTasks(id));
};

export const startMonitoringManifestTasks = (
  id = SUBSCRIPTIONS_MONITOR_TASKS_ID,
  interval = SUBSCRIPTIONS_MONITOR_TASKS_INTERVAL,
) => (dispatch, getState) => {
  if (selectIsMonitorActive(getState(), id)) {
    return dispatch({
      type: SUBSCRIPTIONS_START_MONITORING_MANIFEST_TASKS_FAILED,
      payload: { id },
    });
  }

  const params = {
    search_id: id,
    type: 'all',
    active_only: false,
    action_types: SUBSCRIPTIONS_BLOCKING_FOREMAN_TASK_TYPES,
  };

  const payload = { id, interval, params };

  dispatch({
    type: SUBSCRIPTIONS_START_MONITORING_MANIFEST_TASKS,
    payload,
  });

  return dispatch(startMonitoringTasks(payload));
};

export const createSubscriptionParams = (extendedParams = {}) => ({
  ...{ organization_id: orgId() },
  ...propsToSnakeCase(extendedParams),
});

export const loadAvailableQuantities = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: SUBSCRIPTIONS_QUANTITIES_REQUEST });

  const params = createSubscriptionParams(extendedParams);
  return api
    .get(`/organizations/${orgId()}/upstream_subscriptions`, {}, params)
    .then(({ data }) => {
      dispatch({
        type: SUBSCRIPTIONS_QUANTITIES_SUCCESS,
        payload: selectSubscriptionsQuantitiesFromResponse(data),
      });
    })
    .catch(result => dispatch(apiError(SUBSCRIPTIONS_QUANTITIES_FAILURE, result)));
};

export const loadSubscriptions = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: SUBSCRIPTIONS_REQUEST });

  const params = createSubscriptionParams(extendedParams);
  return api
    .get('/subscriptions', {}, params)
    .then(({ data }) => {
      dispatch({
        type: SUBSCRIPTIONS_SUCCESS,
        payload: {
          response: data,
          search: extendedParams.search,
        },
      });
      const poolIds = filterRHSubscriptions(data.results).map(subs => subs.id);
      if (poolIds.length > 0) {
        dispatch(loadAvailableQuantities({ poolIds }));
      }
    })
    .catch(result => dispatch(apiError(SUBSCRIPTIONS_FAILURE, result)));
};

export const updateQuantity = (quantities = {}) => (dispatch) => {
  dispatch({ type: UPDATE_QUANTITY_REQUEST, quantities });

  const params = {
    pools: quantities,
  };

  return api
    .put(`/organizations/${orgId()}/upstream_subscriptions`, params)
    .then(({ data }) => {
      dispatch({
        type: UPDATE_QUANTITY_SUCCESS,
        response: data,
      });
    })
    .catch(result => dispatch(apiError(UPDATE_QUANTITY_FAILURE, result)));
};

export const deleteSubscriptions = poolIds => (dispatch) => {
  dispatch({ type: DELETE_SUBSCRIPTIONS_REQUEST });

  const params = {
    pool_ids: poolIds,
  };

  return api
    .delete(`/organizations/${orgId()}/upstream_subscriptions`, {}, params)
    .then(({ data }) => {
      dispatch({
        type: DELETE_SUBSCRIPTIONS_SUCCESS,
        response: data,
      });
    })
    .catch(result => dispatch(apiError(DELETE_SUBSCRIPTIONS_FAILURE, result)));
};

export const exportSubscriptionsCsv = searchQuery => (dispatch) => {
  const params = createSubscriptionParams({ search: searchQuery });

  dispatch({ type: SUBSCRIPTIONS_EXPORT_CSV, payload: params });

  api.open('/subscriptions.csv', params);
};

export const openManageManifestModal = () => ({ type: SUBSCRIPTIONS_OPEN_MANIFEST_MODAL });
export const closeManageManifestModal = () => ({ type: SUBSCRIPTIONS_CLOSE_MANIFEST_MODAL });

export const openDeleteModal = () => ({ type: SUBSCRIPTIONS_OPEN_DELETE_MODAL });
export const closeDeleteModal = () => ({ type: SUBSCRIPTIONS_CLOSE_DELETE_MODAL });

export const disableDeleteButton = () => ({ type: SUBSCRIPTIONS_DISABLE_DELETE_BUTTON });
export const enableDeleteButton = () => ({ type: SUBSCRIPTIONS_ENABLE_DELETE_BUTTON });

export const updateSearchQuery = searchQuery => ({
  type: SUBSCRIPTIONS_UPDATE_SEARCH_QUERY,
  payload: searchQuery,
});
