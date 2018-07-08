import * as types from '../SubscriptionConstants';

import {
  initialState,
  loadingState,
  loadingQuantitiesState,
  requestSuccessResponse,
  quantitiesSuccessState,
  successState,
  errorState,
  quantitiesErrorState,
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
      payload: {
        message: 'Unable to process request.',
      },
    })).toEqual(errorState);
  });

  it('should have error on UPDATE_QUANTITY_FAILURE', () => {
    expect(reducer(initialState, {
      type: types.UPDATE_QUANTITY_FAILURE,
      payload: {
        message: 'Unable to process request.',
      },
    })).toEqual(errorState);
  });

  it('should flip quantitiesLoading on SUBSCRIPTIONS_QUANTITIES_REQUEST', () => {
    expect(reducer(successState, {
      type: types.SUBSCRIPTIONS_QUANTITIES_REQUEST,
    })).toEqual(loadingQuantitiesState);
  });

  it('should flatten subscriptions response SUBSCRIPTIONS_QUANTITIES_SUCCESS', () => {
    expect(reducer(loadingQuantitiesState, {
      type: types.SUBSCRIPTIONS_QUANTITIES_SUCCESS,
      payload: quantitiesSuccessState.availableQuantities,
    })).toEqual(quantitiesSuccessState);
  });

  it('should have error on SUBSCRIPTIONS_QUANTITIES_FAILURE', () => {
    expect(reducer(successState, {
      type: types.SUBSCRIPTIONS_QUANTITIES_FAILURE,
      payload: {
        message: 'Unable to process request.',
      },
    })).toEqual(quantitiesErrorState);
  });
});
