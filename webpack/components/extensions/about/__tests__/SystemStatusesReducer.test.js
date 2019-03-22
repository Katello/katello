import { testReducerSnapshotWithFixtures } from 'react-redux-test-utils';
import {
  SYSTEM_STATUSES_FAILURE,
  SYSTEM_STATUSES_SUCCESS,
  SYSTEM_STATUSES_REQUEST,
} from '../SystemStatusesConsts';
import reducer from '../SystemStatusesReducer';
import { services } from './SystemStatuses.fixtures';

const fixtures = {
  'should return the initial state': {},
  'should return PENDING': {
    action: {
      type: SYSTEM_STATUSES_REQUEST,
    },
  },
  'should handle success': {
    action: {
      type: SYSTEM_STATUSES_SUCCESS,
      payload: { services },
    },
  },
  'should handle SYSTEM_STATUSES_FAILURE': {
    action: {
      type: SYSTEM_STATUSES_FAILURE,
    },
  },
};

describe('AutoComplete reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));

