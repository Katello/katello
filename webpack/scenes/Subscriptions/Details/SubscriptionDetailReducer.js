import Immutable from 'seamless-immutable';
import {
  SUBSCRIPTION_DETAILS_REQUEST,
  SUBSCRIPTION_DETAILS_SUCCESS,
  SUBSCRIPTION_DETAILS_FAILURE,
} from './SubscriptionDetailConstants';
import {
  PRODUCTS_REQUEST,
  PRODUCTS_SUCCESS,
  PRODUCTS_FAILURE,
} from '../../Products/ProductConstants';

const initialState = Immutable({
  loading: false,
  productContent: {
    results: [],
    total: 0,
  },
});

export default (state = initialState, action) => {
  switch (action.type) {
  case SUBSCRIPTION_DETAILS_REQUEST: {
    return state.set('loading', true);
  }

  case PRODUCTS_REQUEST: {
    return state.set('loading', true);
  }

  case SUBSCRIPTION_DETAILS_SUCCESS: {
    const subscriptionDetails = action.response;

    return state.merge({
      ...subscriptionDetails,
      loading: false,
    });
  }

  case PRODUCTS_SUCCESS: {
    const productContent = { productContent: action.response };

    return state.merge({
      ...productContent,
      loading: false,
    });
  }

  case SUBSCRIPTION_DETAILS_FAILURE: {
    return state.merge({
      error: action.payload.message,
      loading: false,
    });
  }

  case PRODUCTS_FAILURE: {
    return state.merge({
      error: action.payload.message,
      loading: false,
    });
  }

  default:
    return state;
  }
};
