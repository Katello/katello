import * as types from '../ManifestConstants';

import {
  manifestActionsInitialState,
  manifestActionsLoadingState,
  taskSuccessResponse,
  manifestActionsSuccessState,
  manifestActionsErrorState,
} from './manifest.fixtures';
import reducer from '../ManifestReducer';

describe('manifest reducer', () => {
  const errorResult = {
    response: {
      data: 'Unable to process request.',
    },
  };

  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(manifestActionsInitialState);
  });

  it('should keep loading state on UPLOAD_MANIFEST_REQUEST', () => {
    expect(reducer(manifestActionsInitialState, {
      type: types.UPLOAD_MANIFEST_REQUEST,
    })).toEqual(manifestActionsLoadingState);
  });

  it('should flatten response UPLOAD_MANIFEST_SUCCESS', () => {
    expect(reducer(manifestActionsInitialState, {
      type: types.UPLOAD_MANIFEST_SUCCESS,
      response: taskSuccessResponse,
    })).toEqual(manifestActionsSuccessState);
  });

  it('should have error on UPLOAD_MANIFEST_FAILURE', () => {
    expect(reducer(manifestActionsInitialState, {
      type: types.UPLOAD_MANIFEST_FAILURE,
      result: errorResult,
    })).toEqual(manifestActionsErrorState);
  });

  it('should keep loading state on REFRESH_MANIFEST_REQUEST', () => {
    expect(reducer(manifestActionsInitialState, {
      type: types.REFRESH_MANIFEST_REQUEST,
    })).toEqual(manifestActionsLoadingState);
  });

  it('should flatten response REFRESH_MANIFEST_SUCCESS', () => {
    expect(reducer(manifestActionsInitialState, {
      type: types.REFRESH_MANIFEST_SUCCESS,
      response: taskSuccessResponse,
    })).toEqual(manifestActionsSuccessState);
  });

  it('should have error on REFRESH_MANIFEST_FAILURE', () => {
    expect(reducer(manifestActionsInitialState, {
      type: types.REFRESH_MANIFEST_FAILURE,
      result: errorResult,
    })).toEqual(manifestActionsErrorState);
  });

  it('should keep loading state on DELETE_MANIFEST_REQUEST', () => {
    expect(reducer(manifestActionsInitialState, {
      type: types.DELETE_MANIFEST_REQUEST,
    })).toEqual(manifestActionsLoadingState);
  });

  it('should flatten response DELETE_MANIFEST_SUCCESS', () => {
    expect(reducer(manifestActionsInitialState, {
      type: types.DELETE_MANIFEST_SUCCESS,
      response: taskSuccessResponse,
    })).toEqual(manifestActionsSuccessState);
  });

  it('should have error on DELETE_MANIFEST_FAILURE', () => {
    expect(reducer(manifestActionsInitialState, {
      type: types.DELETE_MANIFEST_FAILURE,
      result: errorResult,
    })).toEqual(manifestActionsErrorState);
  });
});
