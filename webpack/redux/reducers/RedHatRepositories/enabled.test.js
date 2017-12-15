import * as types from '../../consts';

import {
  initialState,
  loadingState,
  requestSuccessResponse,
  successState,
  errorState,
} from './enabled.fixtures';
import reducer from './enabled';

describe('enabled reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should keep loading state on ENABLED_REPOSITORIES_REQUEST', () => {
    expect(reducer(initialState, {
      type: types.ENABLED_REPOSITORIES_REQUEST,
    })).toEqual(loadingState);
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
    })).toEqual(errorState);
  });
});
