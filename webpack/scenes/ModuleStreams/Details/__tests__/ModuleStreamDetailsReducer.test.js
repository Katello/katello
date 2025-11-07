import { initialApiState } from '../../../../services/api';
import reducer from '../ModuleStreamDetailsReducer';
import {
  MODULE_STREAM_DETAILS_REQUEST,
  MODULE_STREAM_DETAILS_SUCCESS,
  MODULE_STREAM_DETAILS_FAILURE,
} from '../ModuleStreamDetailsConstants';
import { details } from './moduleStreamDetails.fixtures';

describe('ModuleStreamDetails reducer', () => {
  test('returns the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialApiState);
  });

  test('handles MODULE_STREAM_DETAILS_REQUEST', () => {
    const action = {
      type: MODULE_STREAM_DETAILS_REQUEST,
    };

    const state = reducer(initialApiState, action);

    expect(state.loading).toBe(true);
  });

  test('handles MODULE_STREAM_DETAILS_SUCCESS', () => {
    const action = {
      type: MODULE_STREAM_DETAILS_SUCCESS,
      response: details,
    };

    const state = reducer(initialApiState, action);

    expect(state.loading).toBe(false);
    expect(state.id).toBe(details.id);
    expect(state.name).toBe(details.name);
    expect(state.stream).toBe(details.stream);
    expect(state.profiles).toEqual(details.profiles);
    expect(state.repositories).toEqual(details.repositories);
    expect(state.artifacts).toEqual(details.artifacts);
  });

  test('handles MODULE_STREAM_DETAILS_FAILURE', () => {
    const errorMessage = 'things have gone terribly wrong';
    const action = {
      type: MODULE_STREAM_DETAILS_FAILURE,
      payload: {
        message: errorMessage,
      },
    };

    const state = reducer(initialApiState, action);

    expect(state.loading).toBe(false);
    expect(state.error).toBe(errorMessage);
  });
});
