import * as types from '../ManifestConstants';

import {
  manifestHistoryInitialState,
  manifestHistoryLoadingState,
  manifestHistorySuccessResponse,
  manifestHistorySuccessState,
  manifestHistoryErrorState,
} from './manifest.fixtures';
import reducer from '../ManifestHistoryReducer';

describe('manifest history reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(manifestHistoryInitialState);
  });

  it('should keep loading state on MANIFEST_HISTORY_REQUEST', () => {
    expect(reducer(manifestHistoryInitialState, {
      type: types.MANIFEST_HISTORY_REQUEST,
    })).toEqual(manifestHistoryLoadingState);
  });

  it('should flatten response MANIFEST_HISTORY_SUCCESS', () => {
    expect(reducer(manifestHistoryInitialState, {
      type: types.MANIFEST_HISTORY_SUCCESS,
      response: manifestHistorySuccessResponse,
    })).toEqual(manifestHistorySuccessState);
  });

  it('should have error on MANIFEST_HISTORY_FAILURE', () => {
    expect(reducer(manifestHistoryInitialState, {
      type: types.MANIFEST_HISTORY_FAILURE,
      error: 'Unable to process request.',
    })).toEqual(manifestHistoryErrorState);
  });
});
