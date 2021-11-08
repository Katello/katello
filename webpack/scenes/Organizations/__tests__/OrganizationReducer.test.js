import * as types from '../OrganizationConstants';

import {
  initialState,
  loadingState,
  requestSuccessResponse,
  successState,
  errorState,
} from './organizations.fixtures';
import reducer from '../OrganizationReducer';

describe('organizations reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should keep loading state on GET_ORGANIZATION_REQUEST', () => {
    expect(reducer(initialState, {
      type: types.GET_ORGANIZATION_REQUEST,
    })).toEqual(loadingState);
  });

  it('should flatten organization response GET_ORGANIZATION_SUCCESS', () => {
    expect(reducer(initialState, {
      type: types.GET_ORGANIZATION_SUCCESS,
      response: requestSuccessResponse,
    })).toEqual(successState);
  });

  it('should have error on GET_ORGANIZATION_FAILURE', () => {
    expect(reducer(initialState, {
      type: types.GET_ORGANIZATION_FAILURE,
      error: 'Unable to process request.',
    })).toEqual(errorState);
  });
});
