import Immutable from 'seamless-immutable';
import { initialApiState } from '../../services/api';
import { TASK_BULK_SEARCH_SUCCESS, RESET_TASKS, GET_TASK_SUCCESS } from '../Tasks/TaskConstants';

import {
  SUBSCRIPTIONS_REQUEST,
  SUBSCRIPTIONS_SUCCESS,
  SUBSCRIPTIONS_FAILURE,
  SUBSCRIPTIONS_QUANTITIES_REQUEST,
  SUBSCRIPTIONS_QUANTITIES_SUCCESS,
  SUBSCRIPTIONS_QUANTITIES_FAILURE,
  SUBSCRIPTIONS_COLUMNS_REQUEST,
  UPDATE_SUBSCRIPTION_COLUMNS,
  UPDATE_QUANTITY_REQUEST,
  UPDATE_QUANTITY_SUCCESS,
  UPDATE_QUANTITY_FAILURE,
  DELETE_SUBSCRIPTIONS_REQUEST,
  DELETE_SUBSCRIPTIONS_SUCCESS,
  DELETE_SUBSCRIPTIONS_FAILURE,
  SUBSCRIPTIONS_UPDATE_SEARCH_QUERY,
  SUBSCRIPTIONS_OPEN_MANIFEST_MODAL,
  SUBSCRIPTIONS_CLOSE_MANIFEST_MODAL,
  SUBSCRIPTIONS_OPEN_DELETE_MODAL,
  SUBSCRIPTIONS_CLOSE_DELETE_MODAL,
  SUBSCRIPTIONS_OPEN_TASK_MODAL,
  SUBSCRIPTIONS_CLOSE_TASK_MODAL,
  SUBSCRIPTIONS_DISABLE_DELETE_BUTTON,
  SUBSCRIPTIONS_ENABLE_DELETE_BUTTON,
} from './SubscriptionConstants';
import { GET_SETTING_SUCCESS } from '../../move_to_foreman/Settings/SettingsConstants';

const initialState = Immutable({
  ...initialApiState,
  disconnected: false,
  searchQuery: '',
  manifestModalOpened: false,
  deleteModalOpened: false,
  taskModalOpened: false,
  deleteButtonDisabled: true,
  quantitiesLoading: false,
  availableQuantities: null,
  tasks: [],
  tableColumns: [],
  selectedTableColumns: [],
});

export default (state = initialState, action) => {
  switch (action.type) {
    case SUBSCRIPTIONS_REQUEST:
    case UPDATE_QUANTITY_REQUEST:
    case DELETE_SUBSCRIPTIONS_REQUEST:
      return state.set('loading', true);
    case SUBSCRIPTIONS_COLUMNS_REQUEST:
      return state
        .set('tableColumns', action.payload.tableColumns);
    case UPDATE_SUBSCRIPTION_COLUMNS:
      return state
        .set('selectedTableColumns', action.payload.enabledColumns);
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
      return state.merge({
        quantitiesLoading: true,
        availableQuantities: null,
      });

    case SUBSCRIPTIONS_QUANTITIES_SUCCESS: {
      return state.merge({
        quantitiesLoading: false,
        availableQuantities: action.payload,
      });
    }

    case SUBSCRIPTIONS_QUANTITIES_FAILURE: {
      return state.merge({
        quantitiesLoading: false,
        availableQuantities: {},
      });
    }

    case TASK_BULK_SEARCH_SUCCESS: {
      const tasks = action.response.results;
      const prevTasksSize = state.tasks.length;
      const shouldInitTasks = prevTasksSize === 0 && tasks.length > 0;
      const isTaskFinished = prevTasksSize > 0 && !state.tasks[0].pending;

      if (shouldInitTasks || isTaskFinished) {
        return state.set('tasks', tasks);
      }
      return state;
    }

    case GET_TASK_SUCCESS: {
      return state.set('tasks', [action.response]);
    }

    case RESET_TASKS: {
      return state.set('tasks', []);
    }

    case GET_SETTING_SUCCESS: {
      if (action.response.name === 'content_disconnected') {
        return state.set('disconnected', action.response.value);
      }

      return state;
    }

    case SUBSCRIPTIONS_UPDATE_SEARCH_QUERY:
      return state.set('searchQuery', action.payload);

    case SUBSCRIPTIONS_OPEN_MANIFEST_MODAL:
      return state.set('manifestModalOpened', true);
    case SUBSCRIPTIONS_CLOSE_MANIFEST_MODAL:
      return state.set('manifestModalOpened', false);

    case SUBSCRIPTIONS_OPEN_DELETE_MODAL:
      return state.set('deleteModalOpened', true);
    case SUBSCRIPTIONS_CLOSE_DELETE_MODAL:
      return state.set('deleteModalOpened', false);

    case SUBSCRIPTIONS_OPEN_TASK_MODAL:
      return state.set('taskModalOpened', true);
    case SUBSCRIPTIONS_CLOSE_TASK_MODAL:
      return state.set('taskModalOpened', false);

    case SUBSCRIPTIONS_DISABLE_DELETE_BUTTON:
      return state.set('deleteButtonDisabled', true);
    case SUBSCRIPTIONS_ENABLE_DELETE_BUTTON:
      return state.set('deleteButtonDisabled', false);

    default:
      return state;
  }
};
