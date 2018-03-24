import api, { orgId } from '../../../services/api';
import { propsToSnakeCase } from '../../../services/index';

import {
  UPSTREAM_SUBSCRIPTIONS_REQUEST,
  UPSTREAM_SUBSCRIPTIONS_SUCCESS,
  UPSTREAM_SUBSCRIPTIONS_FAILURE,
} from './UpstreamSubscriptionsContstants';

export const loadUpstreamSubscriptions = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: UPSTREAM_SUBSCRIPTIONS_REQUEST });

  const params = {
    ...{ organization_id: orgId },
    ...propsToSnakeCase(extendedParams),
  };

  return api
    .get(`/organizations/${orgId}/upstream_subscriptions`, {}, params)
    .then(({ data }) => {
      dispatch({
        type: UPSTREAM_SUBSCRIPTIONS_SUCCESS,
        response: data,
        search: extendedParams.search,
      });
    })
    .catch((result) => {
      dispatch({
        type: UPSTREAM_SUBSCRIPTIONS_FAILURE,
        result,
      });
    });
};

export default loadUpstreamSubscriptions;
