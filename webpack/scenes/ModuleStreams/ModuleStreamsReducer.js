import { initialApiState } from '../../services/api';
import {
  MODULE_STREAMS_REQUEST,
  MODULE_STREAMS_SUCCESS,
  MODULE_STREAMS_FAILURE,
} from './ModuleStreamsConstants';

const initialState = initialApiState;

export default (state = initialState, action) => {
  switch (action.type) {
  case MODULE_STREAMS_REQUEST: {
    return state.set('loading', true);
  }

  case MODULE_STREAMS_SUCCESS: {
    const {
      results, page, per_page, subtotal, // eslint-disable-line camelcase
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

  case MODULE_STREAMS_FAILURE: {
    return state.merge({
      error: action.error,
      loading: false,
    });
  }

  default:
    return state;
  }
};
