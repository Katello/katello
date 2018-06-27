import * as types from '../SubscriptionDetailConstants';

import {
  initialState,
  loadingState,
  subDetails,
  successState,
} from './subscriptionDetails.fixtures';
import reducer from '../SubscriptionDetailReducer';

describe('subscriptions reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should keep loading state on SUBSCRIPTION_DETAILS_REQUEST', () => {
    expect(reducer(initialState, {
      type: types.SUBSCRIPTION_DETAILS_REQUEST,
    })).toEqual(loadingState);
  });

  it('load subscription details on SUBSCRIPTION_DETAILS_SUCCESS', () => {
    expect(reducer(initialState, {
      type: types.SUBSCRIPTION_DETAILS_SUCCESS,
      response: subDetails,
    })).toEqual(successState);
  });

  it('load error on SUBSCRIPTION_DETAILS_FAILURE', () => {
    const error = 'nothing worked';
    expect(reducer(initialState, {
      type: types.SUBSCRIPTION_DETAILS_FAILURE,
      payload: {
        message: error,
      },
    })).toEqual({
      ...initialState,
      error,
    });
  });
});
