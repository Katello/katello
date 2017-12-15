import Immutable from 'seamless-immutable';

import {
  REPOSITORY_SETS_REQUEST,
  REPOSITORY_SETS_SUCCESS,
  REPOSITORY_SETS_FAILURE,
} from '../../consts';

const initialState = Immutable({ loading: true, results: [] });

export default (state = initialState, action) => {
  switch (action.type) {
    case REPOSITORY_SETS_REQUEST:
      return state.set('loading', true);

    case REPOSITORY_SETS_SUCCESS:
      return Immutable({
        results: action.response.results,
        loading: false,
      });

    case REPOSITORY_SETS_FAILURE:
      return Immutable({
        error: action.error,
        loading: false,
      });

    default:
      return state;
  }
};
