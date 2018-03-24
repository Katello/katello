import * as types from '../UpstreamSubscriptionsContstants';

import {
  initialState,
  loadingState,
  requestSuccessResponse,
  successState,
  errorState,
} from './upstreamSubscriptions.fixtures';
import reducer from '../UpstreamSubscriptionsReducer';

describe('enabled reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should keep loading state on ENABLED_REPOSITORIES_REQUEST', () => {
    expect(reducer(initialState, {
      type: types.UPSTREAM_SUBSCRIPTIONS_REQUEST,
    })).toEqual(loadingState);
  });

  it('should flatten repositories response ENABLED_REPOSITORIES_SUCCESS', () => {
    expect(reducer(initialState, {
      type: types.UPSTREAM_SUBSCRIPTIONS_SUCCESS,
      response: requestSuccessResponse,
    })).toEqual(successState);
  });

  it('should have error on ENABLED_REPOSITORIES_FAILURE', () => {
    expect(reducer(initialState, {
      type: types.UPSTREAM_SUBSCRIPTIONS_FAILURE,
      error: 'Unable to process request.',
    })).toEqual(errorState);
  });
});
