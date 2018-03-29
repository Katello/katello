import { initialApiState } from '../../../services/api';

import {
  UPSTREAM_SUBSCRIPTIONS_REQUEST,
  UPSTREAM_SUBSCRIPTIONS_SUCCESS,
  UPSTREAM_SUBSCRIPTIONS_FAILURE,
} from './UpstreamSubscriptionsContstants';

const initialState = initialApiState;

export default (state = initialState, action) => {
  switch (action.type) {
    case UPSTREAM_SUBSCRIPTIONS_REQUEST:
      return state.set('loading', true);

    case UPSTREAM_SUBSCRIPTIONS_SUCCESS: {
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

    case UPSTREAM_SUBSCRIPTIONS_FAILURE:
      return state.merge({
        error: action.error,
        loading: false,
      });

    default:
      return state;
  }
};
