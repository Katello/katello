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

import { pollTaskUntilDone } from '../../Tasks/TaskActions';
import { POLL_TASK_INTERVAL } from '../../Tasks/TaskConstants';

export const loadUpstreamSubscriptions = (extendedParams = {}) => async (dispatch) => {
  dispatch({ type: UPSTREAM_SUBSCRIPTIONS_REQUEST });

  const params = {
    ...{ organization_id: orgId(), attachable: true },
    ...propsToSnakeCase(extendedParams),
  };

  try {
    const { data } = await api.get(`/organizations/${orgId()}/upstream_subscriptions`, {}, params);
    return dispatch({
      type: UPSTREAM_SUBSCRIPTIONS_SUCCESS,
      response: data,
      search: extendedParams.search,
    });
  } catch (error) {
    return dispatch(apiError(UPSTREAM_SUBSCRIPTIONS_FAILURE, error));
  }
};

export const saveUpstreamSubscriptions = upstreamSubscriptions => async (dispatch) => {
  dispatch({ type: SAVE_UPSTREAM_SUBSCRIPTIONS_REQUEST });

  const params = {
    ...propsToSnakeCase(upstreamSubscriptions),
  };

  try {
    const { data } = await api.post(`/organizations/${orgId()}/upstream_subscriptions`, params);

    dispatch(pollTaskUntilDone(data.id, {}, POLL_TASK_INTERVAL, Number(orgId())));

    return dispatch({
      type: SAVE_UPSTREAM_SUBSCRIPTIONS_SUCCESS,
      response: data,
    });
  } catch (error) {
    return dispatch(apiError(SAVE_UPSTREAM_SUBSCRIPTIONS_FAILURE, error));
  }
};

export default loadUpstreamSubscriptions;
