import { initialApiState } from '../../../services/api';

import {
  UPSTREAM_SUBSCRIPTIONS_REQUEST,
  UPSTREAM_SUBSCRIPTIONS_SUCCESS,
  UPSTREAM_SUBSCRIPTIONS_FAILURE,
  SAVE_UPSTREAM_SUBSCRIPTIONS_REQUEST,
  SAVE_UPSTREAM_SUBSCRIPTIONS_SUCCESS,
  SAVE_UPSTREAM_SUBSCRIPTIONS_FAILURE,
} from './UpstreamSubscriptionsConstants';

const initialState = initialApiState;

export default (state = initialState, action) => {
  switch (action.type) {
  case UPSTREAM_SUBSCRIPTIONS_REQUEST:
    return state.set('loading', true);

  case UPSTREAM_SUBSCRIPTIONS_SUCCESS: {
    const {
      page, per_page, total, results, // eslint-disable-line camelcase

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
      itemCount: Number(total),
    });
  }

  case UPSTREAM_SUBSCRIPTIONS_FAILURE:
    return state.merge({
      error: action.payload.message,
      loading: false,
    });

  case SAVE_UPSTREAM_SUBSCRIPTIONS_REQUEST:
    return state.set('loading', true);

  case SAVE_UPSTREAM_SUBSCRIPTIONS_SUCCESS:
    return state.set('task', action.response).set('loading', false);

  case SAVE_UPSTREAM_SUBSCRIPTIONS_FAILURE: {
    return state.set('error', action.payload.message).set('loading', false);
  }

  default:
    return state;
  }
};
