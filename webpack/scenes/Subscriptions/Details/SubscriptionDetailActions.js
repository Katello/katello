import api, { orgId } from '../../../services/api';
import {
  SUBSCRIPTION_DETAILS_REQUEST,
  SUBSCRIPTION_DETAILS_SUCCESS,
  SUBSCRIPTION_DETAILS_FAILURE,
} from './SubscriptionDetailConstants';
import { apiError } from '../../../utils/helpers.js';

export const loadSubscriptionDetails = subscriptionId => async (dispatch) => {
  dispatch({ type: SUBSCRIPTION_DETAILS_REQUEST });

  try {
    const { data } = await api.get(`/organizations/${orgId()}/subscriptions/${subscriptionId}`);
    return dispatch({
      type: SUBSCRIPTION_DETAILS_SUCCESS,
      response: data,
    });
  } catch (error) {
    return dispatch(apiError(SUBSCRIPTION_DETAILS_FAILURE, error));
  }
};

export default loadSubscriptionDetails;
