import { isEmpty } from 'lodash';
import api, { orgId } from '../../services/api';
import { propsToSnakeCase } from '../../services/index';

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
} from './SubscriptionConstants';
import { filterRHSubscriptions } from './SubscriptionHelpers.js';
import { apiError } from '../../move_to_foreman/common/helpers.js';

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
        response: data,
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
        response: data,
        search: extendedParams.search,
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

export const deleteSubscriptions = poolIds => (dispatch) => {
  dispatch({ type: DELETE_SUBSCRIPTIONS_REQUEST });

  const params = {
    pool_ids: poolIds,
  };

  return api
    .delete(`/organizations/${(orgId())}/upstream_subscriptions`, {}, params)
    .then(({ data }) => {
      dispatch({
        type: DELETE_SUBSCRIPTIONS_SUCCESS,
        response: data,
      });
    })
    .catch(result => dispatch(apiError(DELETE_SUBSCRIPTIONS_FAILURE, result)));
};

export default loadSubscriptions;
