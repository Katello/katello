import * as types from '../TableConstants';

import {
  requestSuccessResponse,
  tableRecord,
} from './Table.fixtures';
import reducer from '../TableReducer';
import { testReducerSnapshotWithFixtures } from '../../../../move_to_pf/test-utils/testHelpers';

const fixtures = {
  'should return the initial state': {},
  'should keep loading state on TABLES_REQUEST': {
    action: {
      type: types.TABLES_REQUEST,
    },
  },
  'should pull table list from response TABLES_SUCCESS': {
    action: {
      type: types.TABLES_SUCCESS,
      payload: (requestSuccessResponse),
    },
  },
  'should have error on TABLE_REQUEST_FAILURE': {
    action: {
      type: types.TABLES_FAILURE,
    },
  },
  'should create response for CREATE_TABLE_SUCCESS': {
    action: {
      type: types.CREATE_TABLE_SUCCESS,
      payload: [tableRecord],
    },
  },
  'should update response UPDATE_TABLE_SUCCESS': {
    action: {
      type: types.UPDATE_TABLE_SUCCESS,
      payload: [tableRecord],
    },
  },
};
describe('Tables reducer', () => testReducerSnapshotWithFixtures(reducer, fixtures));
