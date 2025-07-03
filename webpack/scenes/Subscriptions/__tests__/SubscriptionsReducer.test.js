import { testReducerSnapshotWithFixtures } from 'react-redux-test-utils';

import {
  SUBSCRIPTIONS_REQUEST,
  SUBSCRIPTIONS_SUCCESS,
  SUBSCRIPTIONS_FAILURE,
  SUBSCRIPTIONS_COLUMNS_REQUEST,
  UPDATE_SUBSCRIPTION_COLUMNS,
  SUBSCRIPTIONS_QUANTITIES_REQUEST,
  SUBSCRIPTIONS_QUANTITIES_SUCCESS,
  SUBSCRIPTIONS_QUANTITIES_FAILURE,
  UPDATE_QUANTITY_REQUEST,
  UPDATE_QUANTITY_SUCCESS,
  UPDATE_QUANTITY_FAILURE,
  DELETE_SUBSCRIPTIONS_REQUEST,
  DELETE_SUBSCRIPTIONS_SUCCESS,
  DELETE_SUBSCRIPTIONS_FAILURE,
  SUBSCRIPTIONS_UPDATE_SEARCH_QUERY,
  SUBSCRIPTIONS_OPEN_DELETE_MODAL,
  SUBSCRIPTIONS_CLOSE_DELETE_MODAL,
  SUBSCRIPTIONS_DISABLE_DELETE_BUTTON,
  SUBSCRIPTIONS_ENABLE_DELETE_BUTTON,
  SUBSCRIPTIONS_RESET_TASKS,
  SUBSCRIPTIONS_TASK_SEARCH_SUCCESS,
  SUBSCRIPTIONS_TASK_SEARCH_FAILURE,
  SUBSCRIPTIONS_POLL_TASK_SUCCESS,
  SUBSCRIPTIONS_POLL_TASK_FAILURE,
} from '../SubscriptionConstants';
import reducer from '../SubscriptionReducer';

import {
  DELETE_MANIFEST_SUCCESS,
  UPLOAD_MANIFEST_SUCCESS,
  REFRESH_MANIFEST_SUCCESS,
} from '../Manifest/ManifestConstants';

const mockTask = {
  id: '12345',
  humanized: {
    action: 'ManifestRefresh',
  },
};

const anotherMockTask = {
  id: '54321',
  humanized: {
    action: 'ManifestDelete',
  },
};

const fixtures = {
  'should return the initial state': {},
  'should handle SUBSCRIPTIONS_REQUEST': {
    action: {
      type: SUBSCRIPTIONS_REQUEST,
    },
  },
  'should handle SUBSCRIPTIONS_COLUMNS_REQUEST': {
    action: {
      type: SUBSCRIPTIONS_COLUMNS_REQUEST,
      payload: {
        tableColumns: ['col1', 'col2', 'col3'],
      },
    },
  },
  'should handle UPDATE_SUBSCRIPTION_COLUMNS': {
    action: {
      type: UPDATE_SUBSCRIPTION_COLUMNS,
      payload: {
        enabledColumns: ['col1', 'col2'],
      },
    },
  },
  'should handle SUBSCRIPTIONS_SUCCESS': {
    action: {
      type: SUBSCRIPTIONS_SUCCESS,
      response: {
        page: 1,
        per_page: 10, // eslint-disable-line camelcase
        subtotal: 20,
        results: 'some-results',
      },
      search: 'some search',
    },
  },
  'should handle DELETE_SUBSCRIPTIONS_SUCCESS': {
    action: {
      type: DELETE_SUBSCRIPTIONS_SUCCESS,
      response: mockTask,
    },
  },
  'should handle DELETE_SUBSCRIPTIONS_REQUEST': {
    action: {
      type: DELETE_SUBSCRIPTIONS_REQUEST,
    },
  },
  'should handle DELETE_SUBSCRIPTIONS_FAILURE': {
    action: {
      type: DELETE_SUBSCRIPTIONS_FAILURE,
    },
  },
  'should handle UPDATE_QUANTITY_REQUEST': {
    action: {
      type: UPDATE_QUANTITY_REQUEST,
    },
  },
  'should handle UPDATE_QUANTITY_SUCCESS': {
    action: {
      type: UPDATE_QUANTITY_SUCCESS,
      response: mockTask,
    },
  },
  'should handle UPDATE_QUANTITY_FAILURE': {
    action: {
      type: UPDATE_QUANTITY_FAILURE,
    },
  },
  'should handle SUBSCRIPTIONS_FAILURE': {
    action: {
      type: SUBSCRIPTIONS_FAILURE,
    },
  },
  'should handle DELETE_MANIFEST_SUCCESS': {
    action: {
      type: DELETE_MANIFEST_SUCCESS,
      response: mockTask,
    },
  },
  'should handle REFRESH_MANIFEST_SUCCESS': {
    action: {
      type: REFRESH_MANIFEST_SUCCESS,
      response: mockTask,
    },
  },
  'should handle UPLOAD_MANIFEST_SUCCESS': {
    action: {
      type: UPLOAD_MANIFEST_SUCCESS,
      response: mockTask,
    },
  },
  'should handle SUBSCRIPTIONS_QUANTITIES_REQUEST': {
    action: {
      type: SUBSCRIPTIONS_QUANTITIES_REQUEST,
    },
  },
  'should handle SUBSCRIPTIONS_QUANTITIES_SUCCESS': {
    action: {
      type: SUBSCRIPTIONS_QUANTITIES_SUCCESS,
      payload: 'some-quantities-data',
    },
  },
  'should handle SUBSCRIPTIONS_QUANTITIES_FAILURE': {
    action: {
      type: SUBSCRIPTIONS_QUANTITIES_FAILURE,
    },
  },
  'should handle SUBSCRIPTIONS_UPDATE_SEARCH_QUERY': {
    action: {
      type: SUBSCRIPTIONS_UPDATE_SEARCH_QUERY,
      payload: 'some-query',
    },
  },
  'should handle SUBSCRIPTIONS_OPEN_DELETE_MODAL': {
    action: {
      type: SUBSCRIPTIONS_OPEN_DELETE_MODAL,
    },
  },
  'should handle SUBSCRIPTIONS_CLOSE_DELETE_MODAL': {
    action: {
      type: SUBSCRIPTIONS_CLOSE_DELETE_MODAL,
    },
  },
  'should handle SUBSCRIPTIONS_DISABLE_DELETE_BUTTON': {
    action: {
      type: SUBSCRIPTIONS_DISABLE_DELETE_BUTTON,
    },
  },
  'should handle SUBSCRIPTIONS_ENABLE_DELETE_BUTTON': {
    action: {
      type: SUBSCRIPTIONS_ENABLE_DELETE_BUTTON,
    },
  },
  'should handle SUBSCRIPTIONS_RESET_TASKS': {
    action: {
      type: SUBSCRIPTIONS_RESET_TASKS,
    },
  },
  'should handle SUBSCRIPTIONS_TASK_SEARCH_SUCCESS': {
    action: {
      type: SUBSCRIPTIONS_TASK_SEARCH_SUCCESS,
      response: {
        results: [mockTask, anotherMockTask],
      },
    },
  },
  'should handle SUBSCRIPTIONS_TASK_SEARCH_FAILURE': {
    action: {
      type: SUBSCRIPTIONS_TASK_SEARCH_FAILURE,
    },
  },
  'should handle SUBSCRIPTIONS_POLL_TASK_SUCCESS': {
    action: {
      type: SUBSCRIPTIONS_POLL_TASK_SUCCESS,
      response: mockTask,
    },
  },
  'should handle SUBSCRIPTIONS_POLL_TASK_FAILURE': {
    action: {
      type: SUBSCRIPTIONS_POLL_TASK_FAILURE,
    },
  },
};

describe('Subscriptions reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
