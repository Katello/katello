import Immutable from 'seamless-immutable';

import {
  MANIFEST_HISTORY_REQUEST,
  MANIFEST_HISTORY_SUCCESS,
  MANIFEST_HISTORY_FAILURE,
} from './ManifestConstants';

const initialState = Immutable({ loading: true, results: [] });

export default (state = initialState, action) => {
  switch (action.type) {
  case MANIFEST_HISTORY_REQUEST:
    return state.set('loading', true);

  case MANIFEST_HISTORY_SUCCESS: {
    const results = action.response;

    return state.merge({
      results,
      loading: false,
    });
  }

  case MANIFEST_HISTORY_FAILURE:
    return state.merge({
      error: action.payload.message,
      loading: false,
    });

  default:
    return state;
  }
};
