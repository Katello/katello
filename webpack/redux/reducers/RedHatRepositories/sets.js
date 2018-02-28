import Immutable from 'seamless-immutable';
import { isEmpty } from 'lodash';

import {
  REPOSITORY_SETS_REQUEST,
  REPOSITORY_SETS_SUCCESS,
  REPOSITORY_SETS_FAILURE,
} from '../../consts';

import { initialState } from './sets.fixtures.js';

export default (state = initialState, action) => {
  if (action.type === REPOSITORY_SETS_REQUEST) {
    return state.set('loading', true);
  } else if (action.type === REPOSITORY_SETS_SUCCESS) {
    const {
      page, per_page, subtotal, results,
    } = action.response;

    return Immutable({
      results,
      pagination: {
        page: Number(page),
        // server can return per_page: null when there's error in the search query,
        // don't store it in such case
        // eslint-disable-next-line camelcase
        perPage: Number(per_page || state.pagination.perPage),
      },
      itemCount: Number(subtotal),
      loading: false,
      searchIsActive: !isEmpty(action.search),
      search: action.search,
    });
  } else if (action.type === REPOSITORY_SETS_FAILURE) {
    return Immutable({
      error: action.error,
      loading: false,
    });
  }
  return state;
};
