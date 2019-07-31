import { testReducerSnapshotWithFixtures } from 'react-redux-test-utils';
import reducer from '../AnsibleCollectionDetailsReducer';
import {
  ANSIBLE_COLLECTION_DETAILS_REQUEST,
  ANSIBLE_COLLECTION_DETAILS_SUCCESS,
  ANSIBLE_COLLECTION_DETAILS_ERROR,
} from '../AnsibleCollectionDetailsConstants';

const fixtures = {
  'should return the initial state': {},
  'should handle ANSIBLE_COLLECTION_DETAILS_REQUEST': {
    action: {
      type: ANSIBLE_COLLECTION_DETAILS_REQUEST,
    },
  },
  'should handle ANSIBLE_COLLECTION_DETAILS_SUCCESS': {
    action: {
      type: ANSIBLE_COLLECTION_DETAILS_SUCCESS,
      payload: {
        results: { data: { id: 1 } },
      },
    },
  },
  'should handle ANSIBLE_COLLECTION_DETAILS_ERROR': {
    action: {
      type: ANSIBLE_COLLECTION_DETAILS_ERROR,
      payload: new Error('things have gone terribly wrong'),
    },
  },
};

describe('AnsibleCollectionDetails reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
