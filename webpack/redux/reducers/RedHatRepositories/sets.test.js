import * as types from '../../consts';

import {
  initialState,
  loadingState,
  requestSuccessResponse,
  successState,
  errorState,
} from './sets.fixtures';
import reducer from './sets';

describe('sets reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should keep loading state on REPOSITORY_SETS_REQUEST', () => {
    expect(reducer(initialState, {
      type: types.REPOSITORY_SETS_REQUEST,
    })).toEqual(loadingState);
  });

  it('should flatten repositories response REPOSITORY_SETS_SUCCESS', () => {
    expect(reducer(initialState, {
      type: types.REPOSITORY_SETS_SUCCESS,
      response: requestSuccessResponse,
    })).toEqual(successState);
  });

  it('should have error on REPOSITORY_SETS_FAILURE', () => {
    expect(reducer(initialState, {
      type: types.REPOSITORY_SETS_FAILURE,
      error: 'Unable to process request.',
    })).toEqual(errorState);
  });
});
