import * as types from '../../../consts';

import {
  contentId,
  productId,
  initialState,
  loadingState,
  requestSuccessResponse,
  successState,
  errorState,
  enabledState,
  enablingState,
  enablingFailedState,

} from '../repositorySetRepositories.fixtures';
import reducer from '../repositorySetRepositories';

describe('repositorySetRepositories reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should set loading state on REPOSITORY_SET_REPOSITORIES_REQUEST', () => {
    expect(reducer(initialState, {
      type: types.REPOSITORY_SET_REPOSITORIES_REQUEST,
      contentId,
    })).toEqual(loadingState);
  });

  it('should flatten repositories response REPOSITORY_SET_REPOSITORIES_SUCCESS', () => {
    expect(reducer(initialState, {
      type: types.REPOSITORY_SET_REPOSITORIES_SUCCESS,
      contentId,
      productId,
      results: requestSuccessResponse.results,
    })).toEqual(successState);
  });

  it('should have error on REPOSITORY_SET_REPOSITORIES_FAILURE', () => {
    expect(reducer(initialState, {
      type: types.REPOSITORY_SET_REPOSITORIES_FAILURE,
      payload: { contentId },
      error: 'Unable to process request.',
    })).toEqual(errorState);
  });

  it('should set enabled to true on REPOSITORY_ENABLED', () => {
    expect(reducer(successState, {
      type: types.REPOSITORY_ENABLED,
      repository: {
        contentId,
        releasever: '7.2',
        arch: 'x86_64',
      },
    })).toEqual(enabledState);
  });

  it('should set enabled to false on REPOSITORY_DISABLED', () => {
    expect(reducer(enabledState, {
      type: types.REPOSITORY_DISABLED,
      repository: {
        contentId,
        releasever: '7.2',
        arch: 'x86_64',
      },
      error: 'Unable to process request.',
    })).toEqual(successState);
  });

  it('sets loading of a repo to true on ENABLE_REPOSITORY_REQUEST', () => {
    expect(reducer(successState, {
      type: types.ENABLE_REPOSITORY_REQUEST,
      repository: {
        contentId,
        releasever: '7.2',
        arch: 'x86_64',
      },
    })).toEqual(enablingState);
  });

  it('sets loading of a repo to false and error to true on ENABLE_REPOSITORY_FAILURE', () => {
    expect(reducer(successState, {
      type: types.ENABLE_REPOSITORY_FAILURE,
      payload: {
        repository: {
          contentId,
          releasever: '7.2',
          arch: 'x86_64',
        },
        error: 'Unable to process request.',
      },
    })).toEqual(enablingFailedState);
  });
});
