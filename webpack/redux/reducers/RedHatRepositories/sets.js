import Immutable from 'seamless-immutable';

import {
  REPOSITORY_SETS_REQUEST,
  REPOSITORY_SETS_SUCCESS,
  REPOSITORY_SETS_FAILURE,
} from '../../consts';

const initialState = Immutable({ loading: true, results: [], page: 1 });

export default (state = initialState, action) => {
  if (action.type === REPOSITORY_SETS_REQUEST) {
    return state.set('loading', true);
  }

  if (action.type === REPOSITORY_SETS_SUCCESS) {
    const {
      page, per_page: perPage, subtotal, total, results,
    } = action.response;

    return Immutable({
      results,
      page,
      perPage,
      subtotal,
      total,
      loading: false,
      searchIsActive: !!action.search,
    });
  }

  if (action.type === REPOSITORY_SETS_FAILURE) {
    return Immutable({
      error: action.error,
      loading: false,
    });
  }

  return state;
};
