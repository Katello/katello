import * as types from '../../../consts';

import {
  initialState,
  recommendedState,
  loadingState,
  requestSuccessResponse,
  successState,
  errorState,
} from '../sets.fixtures';
import reducer from '../sets';

describe('sets reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should update the recommended value on REPOSITORY_SETS_UPDATE_RECOMMENDED', () => {
    expect(reducer(initialState, {
      type: types.REPOSITORY_SETS_UPDATE_RECOMMENDED,
      payload: true,
    })).toEqual(recommendedState);
  });

  it('should keep loading state on REPOSITORY_SETS_REQUEST', () => {
    expect(reducer(initialState, {
      type: types.REPOSITORY_SETS_REQUEST,
    })).toEqual(loadingState);
  });

  it('should flatten repositories response REPOSITORY_SETS_SUCCESS', () => {
    expect(reducer(initialState, {
      type: types.REPOSITORY_SETS_SUCCESS,
      payload: { response: requestSuccessResponse, search: requestSuccessResponse.search },
    })).toEqual(successState);
  });

  it('should have error on REPOSITORY_SETS_FAILURE', () => {
    expect(reducer(initialState, {
      type: types.REPOSITORY_SETS_FAILURE,
      payload: { response: { data: { error: { missing_permissions: ['unknown'] } } } },
    })).toEqual(errorState);
  });
});
