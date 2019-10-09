import * as types from '../../../consts';

import {
  initialState,
  loadingState,
  requestSuccessResponse,
  successState,
  errorState,
  disablingState,
  disabledIndex,
  disablingFailedState,
} from '../enabled.fixtures';
import reducer from '../enabled';

describe('enabled reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should keep loading state on ENABLED_REPOSITORIES_REQUEST', () => {
    expect(reducer(initialState, {
      type: types.ENABLED_REPOSITORIES_REQUEST,
    })).toEqual(loadingState);
  });

  it('does not set loading state on silent ENABLED_REPOSITORIES_REQUEST', () => {
    expect(reducer(successState, {
      type: types.ENABLED_REPOSITORIES_REQUEST,
      silent: true,
    })).toEqual(successState);
  });

  it('should flatten repositories response ENABLED_REPOSITORIES_SUCCESS', () => {
    expect(reducer(initialState, {
      type: types.ENABLED_REPOSITORIES_SUCCESS,
      response: requestSuccessResponse,
    })).toEqual(successState);
  });

  it('should have error on ENABLED_REPOSITORIES_FAILURE', () => {
    expect(reducer(initialState, {
      type: types.ENABLED_REPOSITORIES_FAILURE,
      error: 'Unable to process request.',
      missingPermissions: ['unknown'],
    })).toEqual(errorState);
  });

  it('sets loading for a repo on DISABLE_REPOSITORY_REQUEST', () => {
    expect(reducer(successState, {
      type: types.DISABLE_REPOSITORY_REQUEST,
      repository: successState.repositories[disabledIndex],
    })).toEqual(disablingState);
  });

  it('sets loading for a repo on DISABLE_REPOSITORY_FAILURE', () => {
    expect(reducer(disablingState, {
      type: types.DISABLE_REPOSITORY_FAILURE,
      payload: {
        repository: successState.repositories[disabledIndex],
      },
    })).toEqual(disablingFailedState);
  });
});
