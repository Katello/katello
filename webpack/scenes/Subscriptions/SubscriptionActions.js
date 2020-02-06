import { propsToSnakeCase } from 'foremanReact/common/helpers';

import { isEmpty } from 'lodash';
import api, { orgId } from '../../services/api';

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
  UPDATE_SUBSCRIPTION_COLUMNS,
  DELETE_SUBSCRIPTIONS_REQUEST,
  DELETE_SUBSCRIPTIONS_SUCCESS,
  DELETE_SUBSCRIPTIONS_FAILURE,
  SUBSCRIPTION_TABLE_COLUMNS,
  SUBSCRIPTION_TABLE_DEFAULT_COLUMNS,
  SUBSCRIPTIONS_COLUMNS_REQUEST,
  SUBSCRIPTIONS_UPDATE_SEARCH_QUERY,
  SUBSCRIPTIONS_OPEN_DELETE_MODAL,
  SUBSCRIPTIONS_CLOSE_DELETE_MODAL,
  SUBSCRIPTIONS_OPEN_TASK_MODAL,
  SUBSCRIPTIONS_CLOSE_TASK_MODAL,
  SUBSCRIPTIONS_DISABLE_DELETE_BUTTON,
  SUBSCRIPTIONS_ENABLE_DELETE_BUTTON,
} from './SubscriptionConstants';
import { filterRHSubscriptions, selectSubscriptionsQuantitiesFromResponse } from './SubscriptionHelpers.js';
import { apiError } from '../../move_to_foreman/common/helpers.js';
import { pollTaskUntilDone } from '../Tasks/TaskActions';
import { POLL_TASK_INTERVAL } from '../Tasks/TaskConstants';

export const createSubscriptionParams = (extendedParams = {}) => ({
  ...{
    organization_id: orgId(),
    include_permissions: true,
  },
  ...propsToSnakeCase(extendedParams),
});

export const loadAvailableQuantities = (extendedParams = {}) => async (dispatch) => {
  dispatch({ type: SUBSCRIPTIONS_QUANTITIES_REQUEST });

  const params = createSubscriptionParams(extendedParams);

  try {
    const { data } = await api.get(`/organizations/${orgId()}/upstream_subscriptions`, {}, params);
    return dispatch({
      type: SUBSCRIPTIONS_QUANTITIES_SUCCESS,
      payload: selectSubscriptionsQuantitiesFromResponse(data),
    });
  } catch (error) {
    return dispatch(apiError(SUBSCRIPTIONS_QUANTITIES_FAILURE, error));
  }
};

export const loadSubscriptions = (extendedParams = {}) => async (dispatch) => {
  dispatch({ type: SUBSCRIPTIONS_REQUEST });

  const params = createSubscriptionParams(extendedParams);

  try {
    const { data } = await api.get('/subscriptions', {}, params);
    const result = dispatch({
      type: SUBSCRIPTIONS_SUCCESS,
      response: data,
      search: extendedParams.search,
    });
    const poolIds = filterRHSubscriptions(data.results).map(subs => subs.id);
    if (poolIds.length > 0) {
      dispatch(loadAvailableQuantities({ poolIds }));
    }
    return result;
  } catch (error) {
    return dispatch(apiError(SUBSCRIPTIONS_FAILURE, error));
  }
};

export const updateQuantity = (quantities = {}) => async (dispatch) => {
  dispatch({ type: UPDATE_QUANTITY_REQUEST, quantities });

  const params = {
    pools: quantities,
  };

  try {
    const { data } = await api.put(`/organizations/${orgId()}/upstream_subscriptions`, params);
    return dispatch({
      type: UPDATE_QUANTITY_SUCCESS,
      response: data,
    });
  } catch (error) {
    return dispatch(apiError(UPDATE_QUANTITY_FAILURE, error));
  }
};

export const loadTableColumns = selectedColumns => (dispatch) => {
  const enabledColumns = (isEmpty(selectedColumns) ?
    SUBSCRIPTION_TABLE_DEFAULT_COLUMNS : selectedColumns.columns);
  dispatch({
    type: UPDATE_SUBSCRIPTION_COLUMNS,
    payload: { enabledColumns },
  });

  const tableColumns = SUBSCRIPTION_TABLE_COLUMNS.map((option) => {
    const currentOption = option;
    currentOption.value = enabledColumns.includes(option.key);

    return currentOption;
  });

  dispatch({
    type: SUBSCRIPTIONS_COLUMNS_REQUEST,
    payload: { tableColumns },
  });
};

export const deleteSubscriptions = poolIds => async (dispatch) => {
  dispatch({ type: DELETE_SUBSCRIPTIONS_REQUEST });

  const params = {
    pool_ids: poolIds,
  };

  try {
    const { data } = await api.delete(`/organizations/${(orgId())}/upstream_subscriptions`, {}, params);
    dispatch(pollTaskUntilDone(data.id, {}, POLL_TASK_INTERVAL, Number(orgId())));
    return dispatch({ type: DELETE_SUBSCRIPTIONS_SUCCESS });
  } catch (error) {
    return dispatch(apiError(DELETE_SUBSCRIPTIONS_FAILURE, error));
  }
};

export const updateSearchQuery = query => ({
  type: SUBSCRIPTIONS_UPDATE_SEARCH_QUERY,
  payload: query,
});

export const openDeleteModal = () => ({ type: SUBSCRIPTIONS_OPEN_DELETE_MODAL });
export const closeDeleteModal = () => ({ type: SUBSCRIPTIONS_CLOSE_DELETE_MODAL });

export const openTaskModal = () => ({ type: SUBSCRIPTIONS_OPEN_TASK_MODAL });
export const closeTaskModal = () => ({ type: SUBSCRIPTIONS_CLOSE_TASK_MODAL });

export const disableDeleteButton = () => ({ type: SUBSCRIPTIONS_DISABLE_DELETE_BUTTON });
export const enableDeleteButton = () => ({ type: SUBSCRIPTIONS_ENABLE_DELETE_BUTTON });

export default loadSubscriptions;
