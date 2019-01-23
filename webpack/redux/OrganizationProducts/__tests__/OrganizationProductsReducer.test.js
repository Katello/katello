import { testReducerSnapshotWithFixtures } from 'react-redux-test-utils';

import {
  ORGANIZATION_PRODUCTS_REQUEST,
  ORGANIZATION_PRODUCTS_SUCCESS,
  ORGANIZATION_PRODUCTS_FAILURE,
} from '../OrganizationProductsConstants';
import reducer from '../OrganizationProductsReducer';

const fixtures = {
  'should return the initial state': {},
  'should handle ORGANIZATION_PRODUCTS_REQUEST': {
    action: {
      type: ORGANIZATION_PRODUCTS_REQUEST,
    },
  },
  'should handle ORGANIZATION_PRODUCTS_SUCCESS': {
    action: {
      type: ORGANIZATION_PRODUCTS_SUCCESS,
      payload: {
        results: ['some', 'results'],
      },
    },
  },
  'should handle ORGANIZATION_PRODUCTS_FAILURE': {
    action: {
      type: ORGANIZATION_PRODUCTS_FAILURE,
      payload: new Error('some error'),
    },
  },
};

describe('OrganizationProducts reducer', () => testReducerSnapshotWithFixtures(reducer, fixtures));
