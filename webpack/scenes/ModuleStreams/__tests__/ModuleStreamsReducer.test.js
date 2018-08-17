import {
  MODULE_STREAMS_REQUEST,
  MODULE_STREAMS_SUCCESS,
  MODULE_STREAMS_FAILURE,
} from '../ModuleStreamsConstants';
import {
  initialState,
  loadingState,
  successState,
  results,
} from './moduleStreams.fixtures';
import reducer from '../ModuleStreamsReducer';

describe('module streams reducer', () => {
  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should keep loading state on MODULE_STREAMS_REQUEST', () => {
    expect(reducer(initialState, {
      type: MODULE_STREAMS_REQUEST,
    })).toEqual(loadingState);
  });

  it('load module streams on MODULE_STREAMS_SUCCESS', () => {
    expect(reducer(initialState, {
      type: MODULE_STREAMS_SUCCESS,
      response: {
        ...initialState,
        results,
      },
    })).toEqual(successState);
  });

  it('load error on MODULE_STREAMS_FAILURE', () => {
    const error = 'nothing worked';
    expect(reducer(initialState, {
      type: MODULE_STREAMS_FAILURE,
      error,
    })).toEqual({
      ...initialState,
      loading: false,
      error,
    });
  });
});
