import Immutable from 'seamless-immutable';

import { initialApiState } from '../../services/api';

import {
  CONTENT_VIEWS_REQUEST,
  CONTENT_VIEWS_SUCCESS,
  CONTENT_VIEWS_FAILURE,
  CONTENT_VIEW_DETAILS_REQUEST,
  CONTENT_VIEW_DETAILS_SUCCESS,
  CONTENT_VIEW_DETAILS_FAILURE,
} from './ContentViewsConstants';

const initialState = Immutable({
  ...initialApiState,
  detailsMap: {},
});

const updateContentViewDetails = (state, contentViewId, details) => state.merge({
  detailsMap: {
    ...state.detailsMap,
    [contentViewId]: details,
  },
});

export default (state = initialState, action) => {
  switch (action.type) {
    case CONTENT_VIEWS_REQUEST:
      return state.set('loading', true);

    case CONTENT_VIEWS_SUCCESS: {
      const {
        page,
        per_page, // eslint-disable-line camelcase
        subtotal,
        results,
      } = action.response;

      return state.merge({
        results,
        loading: false,
        pagination: {
          page: Number(page),
          // eslint-disable-next-line camelcase
          perPage: Number(per_page || state.pagination.perPage),
        },
        itemCount: Number(subtotal),
      });
    }

    case CONTENT_VIEWS_FAILURE:
      return state
        .set('loading', false)
        .set('results', []);

    case CONTENT_VIEW_DETAILS_REQUEST: {
      const { contentViewId } = action;
      const details = { loading: true };
      return updateContentViewDetails(state, contentViewId, details);
    }

    case CONTENT_VIEW_DETAILS_SUCCESS: {
      const { contentViewId, response } = action;
      const details = { ...response, loading: true };
      return updateContentViewDetails(state, contentViewId, details);
    }

    case CONTENT_VIEW_DETAILS_FAILURE: {
      const { contentViewId } = action;
      const details = { loading: false };
      return updateContentViewDetails(state, contentViewId, details);
    }

    default:
      return state;
  }
};
