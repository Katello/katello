import { testReducerSnapshotWithFixtures } from '../../../move_to_pf/test-utils/testHelpers';

import {
  SUBSCRIPTIONS_REQUEST,
  SUBSCRIPTIONS_SUCCESS,
  SUBSCRIPTIONS_FAILURE,
  SUBSCRIPTIONS_QUANTITIES_REQUEST,
  SUBSCRIPTIONS_QUANTITIES_SUCCESS,
  SUBSCRIPTIONS_QUANTITIES_FAILURE,
  UPDATE_QUANTITY_REQUEST,
  UPDATE_QUANTITY_SUCCESS,
  UPDATE_QUANTITY_FAILURE,
  DELETE_SUBSCRIPTIONS_REQUEST,
  DELETE_SUBSCRIPTIONS_SUCCESS,
  DELETE_SUBSCRIPTIONS_FAILURE,
  SUBSCRIPTIONS_OPEN_MANIFEST_MODAL,
  SUBSCRIPTIONS_CLOSE_MANIFEST_MODAL,
  SUBSCRIPTIONS_OPEN_DELETE_MODAL,
  SUBSCRIPTIONS_CLOSE_DELETE_MODAL,
  SUBSCRIPTIONS_DISABLE_DELETE_BUTTON,
  SUBSCRIPTIONS_ENABLE_DELETE_BUTTON,
  SUBSCRIPTIONS_UPDATE_SEARCH_QUERY,
} from '../SubscriptionConstants';
import { GET_SETTING_SUCCESS } from '../../../move_to_foreman/Settings/SettingsConstants';
import reducer from '../SubscriptionReducer';

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
  'should handle SUBSCRIPTIONS_SUCCESS': {
    action: {
      type: SUBSCRIPTIONS_SUCCESS,
      payload: {
        response: {
          page: 1,
          per_page: 10, // eslint-disable-line camelcase
          subtotal: 20,
          results: 'some-results',
        },
        search: 'some search',
      },
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
  'should handle SUBSCRIPTIONS_OPEN_MANIFEST_MODAL': {
    action: {
      type: SUBSCRIPTIONS_OPEN_MANIFEST_MODAL,
    },
  },
  'should handle SUBSCRIPTIONS_CLOSE_MANIFEST_MODAL': {
    action: {
      type: SUBSCRIPTIONS_CLOSE_MANIFEST_MODAL,
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
  'should handle SUBSCRIPTIONS_UPDATE_SEARCH_QUERY': {
    action: {
      type: SUBSCRIPTIONS_UPDATE_SEARCH_QUERY,
      payload: 'some-search-query',
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
};

describe('TasksMonitor reducer', () => testReducerSnapshotWithFixtures(reducer, fixtures));
