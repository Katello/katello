import Immutable from 'seamless-immutable';
import { get } from 'lodash';
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
} from './SubscriptionConstants';

import {
  DELETE_MANIFEST_SUCCESS,
  UPLOAD_MANIFEST_SUCCESS,
  REFRESH_MANIFEST_SUCCESS,
  REFRESH_MANIFEST_FAILURE,
  ENABLE_SIMPLE_CONTENT_ACCESS_FAILURE,
  DISABLE_SIMPLE_CONTENT_ACCESS_FAILURE,
  REFRESH_MANIFEST_REQUEST,
  DISABLE_SIMPLE_CONTENT_ACCESS_REQUEST,
  ENABLE_SIMPLE_CONTENT_ACCESS_REQUEST,
  ENABLE_SIMPLE_CONTENT_ACCESS_SUCCESS,
  DISABLE_SIMPLE_CONTENT_ACCESS_SUCCESS,
  SIMPLE_CONTENT_ACCESS_ELIGIBLE_SUCCESS,
  UPLOAD_MANIFEST_FAILURE,
  UPLOAD_MANIFEST_REQUEST,
  DELETE_MANIFEST_FAILURE,
  DELETE_MANIFEST_REQUEST,
} from './Manifest/ManifestConstants';

import {
  PING_UPSTREAM_SUBSCRIPTIONS_SUCCESS,
  PING_UPSTREAM_SUBSCRIPTIONS_FAILURE,
} from './UpstreamSubscriptions/UpstreamSubscriptionsConstants';

const initialState = Immutable({
  ...initialApiState,
  searchQuery: '',
  deleteModalOpened: false,
  deleteButtonDisabled: true,
  quantitiesLoading: false,
  availableQuantities: null,
  task: null,
  tableColumns: [],
  selectedTableColumns: [],
  hasUpstreamConnection: false,
  manifestActionStarted: false,
});

export default (state = initialState, action) => {
  switch (action.type) {
  case SIMPLE_CONTENT_ACCESS_ELIGIBLE_SUCCESS:
    return state.set('simpleContentAccessEligible', action.response.simple_content_access_eligible);
  case PING_UPSTREAM_SUBSCRIPTIONS_SUCCESS:
    return state.set('hasUpstreamConnection', true);
  case PING_UPSTREAM_SUBSCRIPTIONS_FAILURE:
    return state.set('hasUpstreamConnection', false);
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
    return state.merge({
      task: action.response,
      hasUpstreamConnection: false,
      manifestActionStarted: false,
    });

  case SUBSCRIPTIONS_POLL_TASK_SUCCESS:
    return state
      .set('task', action.response);

  case UPDATE_QUANTITY_SUCCESS:
  case UPLOAD_MANIFEST_SUCCESS:
  case REFRESH_MANIFEST_SUCCESS:
  case ENABLE_SIMPLE_CONTENT_ACCESS_SUCCESS:
  case DISABLE_SIMPLE_CONTENT_ACCESS_SUCCESS:
    return state
      .set('task', action.response)
      .set('manifestActionStarted', false);

  case ENABLE_SIMPLE_CONTENT_ACCESS_REQUEST:
  case DISABLE_SIMPLE_CONTENT_ACCESS_REQUEST:
  case REFRESH_MANIFEST_REQUEST:
  case UPLOAD_MANIFEST_REQUEST:
  case DELETE_MANIFEST_REQUEST:
  case UPDATE_QUANTITY_REQUEST:
  case DELETE_SUBSCRIPTIONS_REQUEST:
    return state
      .set('manifestActionStarted', true);

  case ENABLE_SIMPLE_CONTENT_ACCESS_FAILURE:
  case DISABLE_SIMPLE_CONTENT_ACCESS_FAILURE:
  case REFRESH_MANIFEST_FAILURE:
  case UPLOAD_MANIFEST_FAILURE:
  case DELETE_MANIFEST_FAILURE:
  case DELETE_SUBSCRIPTIONS_FAILURE:
  case UPDATE_QUANTITY_FAILURE:
    return state
      .set('manifestActionStarted', false);

  case DELETE_SUBSCRIPTIONS_SUCCESS:
    return state
      .set('task', action.response)
      .set('manifestActionStarted', false)
      .set('deleteButtonDisabled', true);

  case SUBSCRIPTIONS_RESET_TASKS:
  case SUBSCRIPTIONS_TASK_SEARCH_FAILURE:
  case SUBSCRIPTIONS_POLL_TASK_FAILURE:
    return state
      .set('task', null);

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
