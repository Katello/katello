import find from 'lodash/find';
import { initialApiState } from '../../services/api';
import { TASK_BULK_SEARCH_SUCCESS } from '../Tasks/TaskConstants';

import {
  SUBSCRIPTIONS_REQUEST,
  SUBSCRIPTIONS_SUCCESS,
  SUBSCRIPTIONS_FAILURE,
  MANIFEST_TASKS_BULK_SEARCH_ID,
} from './SubscriptionConstants';

const initialState = initialApiState;

export default (state = initialState, action) => {
  switch (action.type) {
    case SUBSCRIPTIONS_REQUEST:
      return state.set('loading', true).set('tasks', []);

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

    case SUBSCRIPTIONS_FAILURE:
      return state.merge({
        error: action.error,
        loading: false,
      });

    case TASK_BULK_SEARCH_SUCCESS: {
      let tasks = [];

      const search = find(action.response, bulkSearch =>
        bulkSearch.search_params.search_id === MANIFEST_TASKS_BULK_SEARCH_ID);

      if (search) {
        tasks = search.results;
      }

      return state.set('tasks', tasks);
    }

    default:
      return state;
  }
};
