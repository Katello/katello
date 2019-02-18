import { propsToSnakeCase } from 'foremanReact/common/helpers';

import api, { orgId } from '../../../services/api';
import { apiError } from '../../../move_to_foreman/common/helpers.js';

import {
  UPSTREAM_SUBSCRIPTIONS_REQUEST,
  UPSTREAM_SUBSCRIPTIONS_SUCCESS,
  UPSTREAM_SUBSCRIPTIONS_FAILURE,
  SAVE_UPSTREAM_SUBSCRIPTIONS_REQUEST,
  SAVE_UPSTREAM_SUBSCRIPTIONS_SUCCESS,
  SAVE_UPSTREAM_SUBSCRIPTIONS_FAILURE,
} from './UpstreamSubscriptionsContstants';

export const loadUpstreamSubscriptions = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: UPSTREAM_SUBSCRIPTIONS_REQUEST });

  const params = {
    ...{ organization_id: orgId(), attachable: true },
    ...propsToSnakeCase(extendedParams),
  };

  return api
    .get(`/organizations/${orgId()}/upstream_subscriptions`, {}, params)
    .then(({ data }) => {
      dispatch({
        type: UPSTREAM_SUBSCRIPTIONS_SUCCESS,
        response: data,
        search: extendedParams.search,
      });
    })
    .catch(result => dispatch(apiError(UPSTREAM_SUBSCRIPTIONS_FAILURE, result)));
};

export const saveUpstreamSubscriptions = upstreamSubscriptions => (dispatch) => {
  dispatch({ type: SAVE_UPSTREAM_SUBSCRIPTIONS_REQUEST });

  const params = {
    ...propsToSnakeCase(upstreamSubscriptions),
  };

  return api
    .post(`/organizations/${orgId()}/upstream_subscriptions`, params)
    .then(({ data }) => {
      dispatch({
        type: SAVE_UPSTREAM_SUBSCRIPTIONS_SUCCESS,
        response: data,
      });
    })
    .catch(result => dispatch(apiError(SAVE_UPSTREAM_SUBSCRIPTIONS_FAILURE, result)));
};

export default loadUpstreamSubscriptions;
