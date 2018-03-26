import * as types from '../SubscriptionConstants';

import {
  initialState,
  loadingState,
  requestSuccessResponse,
  successState,
  errorState,
} from './subscriptions.fixtures';
import reducer from '../SubscriptionReducer';

describe('subscriptions reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should keep loading state on SUBSCRIPTIONS_REQUEST', () => {
    expect(reducer(initialState, {
      type: types.SUBSCRIPTIONS_REQUEST,
    })).toEqual(loadingState);
  });

  it('should flatten subscriptions response SUBSCRIPTIONS_SUCCESS', () => {
    expect(reducer(initialState, {
      type: types.SUBSCRIPTIONS_SUCCESS,
      response: requestSuccessResponse,
    })).toEqual(successState);
  });

  it('should have error on SUBSCRIPTIONS_FAILURE', () => {
    expect(reducer(initialState, {
      type: types.SUBSCRIPTIONS_FAILURE,
      error: 'Unable to process request.',
    })).toEqual(errorState);
  });
});
