import * as types from '../UpstreamSubscriptionsConstants';

import {
  initialState,
  loadingState,
  requestSuccessResponse,
  taskSuccessResponse,
  successState,
  errorState, saveSuccessState, initialSaveState, saveErrorState,
} from './upstreamSubscriptions.fixtures';
import reducer from '../UpstreamSubscriptionsReducer';

describe('upstream subscriptions reducer', () => {
  const errorResult = {
    response: {
      data: 'Unable to process request.',
    },
  };

  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should keep loading state on UPSTREAM_SUBSCRIPTIONS_REQUEST', () => {
    expect(reducer(initialState, {
      type: types.UPSTREAM_SUBSCRIPTIONS_REQUEST,
    })).toEqual(loadingState);
  });

  it('should flatten subscriptions response UPSTREAM_SUBSCRIPTIONS_SUCCESS', () => {
    expect(reducer(initialState, {
      type: types.UPSTREAM_SUBSCRIPTIONS_SUCCESS,
      response: requestSuccessResponse,
    })).toEqual(successState);
  });

  it('should have error on UPSTREAM_SUBSCRIPTIONS_FAILURE', () => {
    expect(reducer(initialState, {
      type: types.UPSTREAM_SUBSCRIPTIONS_FAILURE,
      payload: {
        message: 'Unable to process request.',
      },
    })).toEqual(errorState);
  });

  it('should flatten response SAVE_UPSTREAM_SUBSCRIPTIONS_SUCCESS', () => {
    expect(reducer(initialSaveState, {
      type: types.SAVE_UPSTREAM_SUBSCRIPTIONS_SUCCESS,
      response: taskSuccessResponse,
    })).toEqual(saveSuccessState);
  });

  it('should have error on SAVE_UPSTREAM_SUBSCRIPTIONS_FAILURE', () => {
    expect(reducer(initialSaveState, {
      type: types.SAVE_UPSTREAM_SUBSCRIPTIONS_FAILURE,
      payload: {
        message: 'Unable to process request.',
        result: errorResult,
      },
    })).toEqual(saveErrorState);
  });
});
