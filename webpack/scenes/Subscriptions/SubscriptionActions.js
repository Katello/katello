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
} from './SubscriptionConstants';
import { filterRHSubscriptions } from './SubscriptionHelpers.js';

const getResponseError = ({ data }) => data && (data.displayMessage || data.error);

export const loadAvailableQuantities = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: SUBSCRIPTIONS_QUANTITIES_REQUEST });

  const params = {
    ...{ organization_id: orgId },
    ...propsToSnakeCase(extendedParams),
  };

  return api
    .get(`/organizations/${orgId}/upstream_subscriptions`, {}, params)
    .then(({ data }) => {
      dispatch({
        type: SUBSCRIPTIONS_QUANTITIES_SUCCESS,
        response: data,
      });
    })
    .catch((result) => {
      dispatch({
        type: SUBSCRIPTIONS_QUANTITIES_FAILURE,
        error: getResponseError(result.response),
      });
    });
};

export const loadSubscriptions = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: SUBSCRIPTIONS_REQUEST });

  const params = {
    ...{ organization_id: orgId },
    ...propsToSnakeCase(extendedParams),
  };

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
    .catch((result) => {
      dispatch({
        type: SUBSCRIPTIONS_FAILURE,
        error: getResponseError(result.response),
      });
    });
};

export const updateQuantity = (quantities = {}) => (dispatch) => {
  dispatch({ type: UPDATE_QUANTITY_REQUEST, quantities });

  const params = {
    pools: quantities,
  };

  return api
    .put(`/organizations/${orgId}/upstream_subscriptions`, params)
    .then(({ data }) => {
      dispatch({
        type: UPDATE_QUANTITY_SUCCESS,
        response: data,
      });
    })
    .catch((result) => {
      dispatch({
        type: UPDATE_QUANTITY_FAILURE,
        error: getResponseError(result.response),
      });
    });
};

export default loadSubscriptions;
