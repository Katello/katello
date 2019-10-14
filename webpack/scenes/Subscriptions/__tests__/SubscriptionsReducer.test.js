import { testReducerSnapshotWithFixtures } from 'react-redux-test-utils';
import { GET_SETTING_SUCCESS } from 'foremanReact/components/Settings/SettingsConstants';

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
  SUBSCRIPTIONS_OPEN_TASK_MODAL,
  SUBSCRIPTIONS_CLOSE_TASK_MODAL,
  SUBSCRIPTIONS_DISABLE_DELETE_BUTTON,
  SUBSCRIPTIONS_ENABLE_DELETE_BUTTON,
  TASK_BULK_SEARCH_SUCCESS,
  GET_TASK_SUCCESS,
  RESET_TASKS,
} from '../SubscriptionConstants';
import reducer from '../SubscriptionReducer';

jest.mock('foremanReact/components/Settings/SettingsConstants');
const fixtures = {
  'should return the initial state': {},
  'should handle SUBSCRIPTIONS_REQUEST': {
    action: {
      type: SUBSCRIPTIONS_REQUEST,
    },
  },
  'should handle UPDATE_QUANTITY_REQUEST': {
    action: {
      type: UPDATE_QUANTITY_REQUEST,
    },
  },
  'should handle DELETE_SUBSCRIPTIONS_REQUEST': {
    action: {
      type: DELETE_SUBSCRIPTIONS_REQUEST,
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
    },
  },
  'should handle UPDATE_QUANTITY_SUCCESS': {
    action: {
      type: UPDATE_QUANTITY_SUCCESS,
    },
  },
  'should handle SUBSCRIPTIONS_FAILURE': {
    action: {
      type: SUBSCRIPTIONS_FAILURE,
    },
  },
  'should handle UPDATE_QUANTITY_FAILURE': {
    action: {
      type: UPDATE_QUANTITY_FAILURE,
    },
  },
  'should handle DELETE_SUBSCRIPTIONS_FAILURE': {
    action: {
      type: DELETE_SUBSCRIPTIONS_FAILURE,
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
  'should handle SUBSCRIPTIONS_OPEN_TASK_MODAL': {
    action: {
      type: SUBSCRIPTIONS_OPEN_TASK_MODAL,
    },
  },
  'should handle SUBSCRIPTIONS_CLOSE_TASK_MODAL': {
    action: {
      type: SUBSCRIPTIONS_CLOSE_TASK_MODAL,
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
  'should handle GET_SETTING_SUCCESS with content_disconnected response': {
    action: {
      type: GET_SETTING_SUCCESS,
      response: {
        name: 'content_disconnected',
        value: 'some-value',
      },
    },
  },
  'should handle GET_SETTING_SUCCESS without content_disconnected response': {
    action: {
      type: GET_SETTING_SUCCESS,
      response: {
        name: 'some-name',
        value: 'some-value',
      },
    },
  },
  'should handle TASK_BULK_SEARCH_SUCCESS': {
    action: {
      type: TASK_BULK_SEARCH_SUCCESS,
      response: {
        results: ['result1', 'result2'],
      },
    },
  },
  'should handle GET_TASK_SUCCESS': {
    action: {
      type: GET_TASK_SUCCESS,
      response: {
        results: 'some-result',
      },
    },
  },
  'should handle RESET_TASKS': {
    action: {
      type: RESET_TASKS,
      response: {
        results: 'some-result',
      },
    },
  },
};

describe('Subscriptions reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
