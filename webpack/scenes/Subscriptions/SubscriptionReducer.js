import Immutable from 'seamless-immutable';
import { initialApiState } from '../../services/api';
import { TASK_BULK_SEARCH_SUCCESS } from '../Tasks/TaskConstants';

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
} from './SubscriptionConstants';
import { GET_SETTING_SUCCESS } from '../../move_to_foreman/Settings/SettingsConstants';

import { filterManifestTasksFromBulkSearchResponse } from './SubscriptionHelpers';

const initialState = Immutable({
  ...initialApiState,
  quantitiesLoading: false,
  availableQuantities: {},
  tasks: [],
});

export default (state = initialState, action) => {
  switch (action.type) {
    case SUBSCRIPTIONS_REQUEST:
    case UPDATE_QUANTITY_REQUEST:
    case DELETE_SUBSCRIPTIONS_REQUEST:
      return state.set('loading', true);

    case SUBSCRIPTIONS_SUCCESS: {
      const {
        page, per_page, subtotal, results, // eslint-disable-line camelcase
      } = action.response;

      return state.merge({
        results,
        loading: false,
        searchIsActive: !!action.search,
        search: action.search,
        pagination: {
          page: Number(page),
          // eslint-disable-next-line camelcase
          perPage: Number(per_page || state.pagination.perPage),
        },
        itemCount: Number(subtotal),
      });
    }

    case DELETE_SUBSCRIPTIONS_SUCCESS:
      return state.set('loading', false);

    case UPDATE_QUANTITY_SUCCESS:
      return state.set('loading', false);

    case SUBSCRIPTIONS_FAILURE:
      return state
        .set('loading', false)
        .set('results', [])
        .set('itemCount', 0);

    case UPDATE_QUANTITY_FAILURE:
    case DELETE_SUBSCRIPTIONS_FAILURE:
      return state.merge({
        loading: false,
      });

    case SUBSCRIPTIONS_QUANTITIES_REQUEST:
      return state.set('quantitiesLoading', true);

    case SUBSCRIPTIONS_QUANTITIES_SUCCESS: {
      return state.merge({
        quantitiesLoading: false,
        availableQuantities: action.payload,
      });
    }

    case SUBSCRIPTIONS_QUANTITIES_FAILURE: {
      return state.merge({
        quantitiesLoading: false,
      });
    }

    case TASK_BULK_SEARCH_SUCCESS: {
      return state.set('tasks', filterManifestTasksFromBulkSearchResponse(action.response));
    }

    case GET_SETTING_SUCCESS: {
      if (action.response.name === 'content_disconnected') {
        return state.set('disconnected', action.response.value);
      }

      return state;
    }

    default:
      return state;
  }
};
