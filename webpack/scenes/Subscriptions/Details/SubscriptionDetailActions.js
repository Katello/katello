import api, { orgId } from '../../../services/api';
import {
  SUBSCRIPTION_DETAILS_REQUEST,
  SUBSCRIPTION_DETAILS_SUCCESS,
  SUBSCRIPTION_DETAILS_FAILURE,
} from './SubscriptionDetailConstants';
import { apiError } from '../../../move_to_foreman/common/helpers.js';

export const loadSubscriptionDetails = subscriptionId => (dispatch, getState) => {
  dispatch({ type: SUBSCRIPTION_DETAILS_REQUEST });

  return api
    .get(`/organizations/${orgId()}/subscriptions/${subscriptionId}`)
    .then(({ data }) => {
      dispatch({
        type: SUBSCRIPTION_DETAILS_SUCCESS,
        response: data,
      });
    })
    .catch(result => dispatch(apiError(SUBSCRIPTION_DETAILS_FAILURE, result)));
};

export default loadSubscriptionDetails;
