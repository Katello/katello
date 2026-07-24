import api, { orgId } from '../../../services/api';
import { apiError } from '../../../utils/helpers.js';

import {
  PING_UPSTREAM_SUBSCRIPTIONS_SUCCESS,
  PING_UPSTREAM_SUBSCRIPTIONS_FAILURE,
} from './UpstreamSubscriptionsConstants';

const pingUpstreamSubscriptions = () => async (dispatch) => {
  try {
    const { data } = await api.get(`/organizations/${orgId()}/upstream_subscriptions/ping`);

    return dispatch({
      type: PING_UPSTREAM_SUBSCRIPTIONS_SUCCESS,
      payload: data,
    });
  } catch (error) {
    return dispatch(apiError(PING_UPSTREAM_SUBSCRIPTIONS_FAILURE, error));
  }
};

export default pingUpstreamSubscriptions;
