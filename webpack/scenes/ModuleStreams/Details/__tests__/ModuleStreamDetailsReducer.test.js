import { testReducerSnapshotWithFixtures } from 'react-redux-test-utils';
import reducer from '../ModuleStreamDetailsReducer';
import {
  MODULE_STREAM_DETAILS_REQUEST,
  MODULE_STREAM_DETAILS_SUCCESS,
  MODULE_STREAM_DETAILS_FAILURE,
} from '../ModuleStreamDetailsConstants';

const fixtures = {
  'should return the initial state': {},
  'should handle MODULE_STREAM_DETAILS_REQUEST': {
    action: {
      type: MODULE_STREAM_DETAILS_REQUEST,
    },
  },
  'should handle MODULE_STREAM_DETAILS_SUCCESS': {
    action: {
      type: MODULE_STREAM_DETAILS_SUCCESS,
      payload: {
        results: { data: { id: 1 } },
      },
    },
  },
  'should handle MODULE_STREAM_DETAILS_FAILURE': {
    action: {
      type: MODULE_STREAM_DETAILS_FAILURE,
      payload: new Error('things have gone terribly wrong'),
    },
  },
};

describe('ModuleStreamDetails reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
