import Immutable from 'seamless-immutable';
import {
  SUBSCRIPTION_DETAILS_REQUEST,
  SUBSCRIPTION_DETAILS_SUCCESS,
  SUBSCRIPTION_DETAILS_FAILURE,
} from './SubscriptionDetailConstants';

const initialState = Immutable({
  loading: false,
});

export default (state = initialState, action) => {
  switch (action.type) {
    case SUBSCRIPTION_DETAILS_REQUEST: {
      return state.set('loading', true);
    }

    case SUBSCRIPTION_DETAILS_SUCCESS: {
      const subscriptionDetails = action.response;

      return state.merge({
        ...subscriptionDetails,
        loading: false,
      });
    }

    case SUBSCRIPTION_DETAILS_FAILURE: {
      return state.merge({
        error: action.error,
        loading: false,
      });
    }

    default:
      return state;
  }
};
