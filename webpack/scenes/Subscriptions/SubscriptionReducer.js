import Immutable from 'seamless-immutable';
import { get } from 'lodash';
import { GET_SETTING_SUCCESS } from 'foremanReact/components/Settings/SettingsConstants';
import { initialApiState } from '../../services/api';

import {
  SUBSCRIPTIONS_REQUEST,
  SUBSCRIPTIONS_SUCCESS,
  SUBSCRIPTIONS_FAILURE,
  SUBSCRIPTIONS_QUANTITIES_REQUEST,
  SUBSCRIPTIONS_QUANTITIES_SUCCESS,
  SUBSCRIPTIONS_QUANTITIES_FAILURE,
  SUBSCRIPTIONS_COLUMNS_REQUEST,
  UPDATE_SUBSCRIPTION_COLUMNS,
  UPDATE_QUANTITY_SUCCESS,
  DELETE_SUBSCRIPTIONS_SUCCESS,
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
} from './SubscriptionConstants';

import {
  DELETE_MANIFEST_SUCCESS,
  UPLOAD_MANIFEST_SUCCESS,
  REFRESH_MANIFEST_SUCCESS,
} from './Manifest/ManifestConstants';

const initialState = Immutable({
  ...initialApiState,
  disconnected: false,
  searchQuery: '',
  deleteModalOpened: false,
  deleteButtonDisabled: true,
  quantitiesLoading: false,
  availableQuantities: null,
  task: null,
  tableColumns: [],
  selectedTableColumns: [],
});

export default (state = initialState, action) => {
  switch (action.type) {
    case SUBSCRIPTIONS_REQUEST:
      return state.set('loading', true);
    case SUBSCRIPTIONS_COLUMNS_REQUEST:
      return state
        .set('tableColumns', action.payload.tableColumns);
    case UPDATE_SUBSCRIPTION_COLUMNS:
      return state
        .set('selectedTableColumns', action.payload.enabledColumns);
    case SUBSCRIPTIONS_SUCCESS: {
      const {
        page,
        per_page, // eslint-disable-line camelcase
        subtotal,
        results,
        can_import_manifest, // eslint-disable-line camelcase
        can_delete_manifest, // eslint-disable-line camelcase
        can_manage_subscription_allocations, // eslint-disable-line camelcase
        can_edit_organizations, // eslint-disable-line camelcase
      } = action.response;

      return state.merge({
        results,
        activePermissions: {
          can_import_manifest,
          can_delete_manifest,
          can_manage_subscription_allocations,
          can_edit_organizations,
        },
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

    case SUBSCRIPTIONS_FAILURE:
      return state
        .set('loading', false)
        .set('results', [])
        .set('itemCount', 0)
        .set(
          'missingPermissions',
          get(action, ['payload', 'messages', 0, 'missing_permissions']),
        );

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

    case SUBSCRIPTIONS_TASK_SEARCH_SUCCESS: {
      if (!state.task) {
        const tasks = action.response.results;
        if (tasks.length > 0) {
          return state
            .set('task', tasks[0]); // this will be the oldest pending task
        }
      }

      return state;
    }

    case DELETE_MANIFEST_SUCCESS:
    case UPLOAD_MANIFEST_SUCCESS:
    case REFRESH_MANIFEST_SUCCESS:
    case UPDATE_QUANTITY_SUCCESS:
    case SUBSCRIPTIONS_POLL_TASK_SUCCESS:
      return state
        .set('task', action.response);

    case DELETE_SUBSCRIPTIONS_SUCCESS:
      return state
        .set('task', action.response)
        .set('deleteButtonDisabled', true);

    case SUBSCRIPTIONS_RESET_TASKS:
    case SUBSCRIPTIONS_TASK_SEARCH_FAILURE:
    case SUBSCRIPTIONS_POLL_TASK_FAILURE:
      return state
        .set('task', null);

    case GET_SETTING_SUCCESS: {
      if (action.response.name === 'content_disconnected') {
        return state.set('disconnected', action.response.value);
      }

      return state;
    }

    case SUBSCRIPTIONS_UPDATE_SEARCH_QUERY:
      return state.set('searchQuery', action.payload);

    case SUBSCRIPTIONS_OPEN_DELETE_MODAL:
      return state.set('deleteModalOpened', true);
    case SUBSCRIPTIONS_CLOSE_DELETE_MODAL:
      return state.set('deleteModalOpened', false);

    case SUBSCRIPTIONS_DISABLE_DELETE_BUTTON:
      return state.set('deleteButtonDisabled', true);
    case SUBSCRIPTIONS_ENABLE_DELETE_BUTTON:
      return state.set('deleteButtonDisabled', false);

    default:
      return state;
  }
};
