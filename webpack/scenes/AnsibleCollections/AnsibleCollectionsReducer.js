import { initialApiState } from '../../services/api';
import {
  ANSIBLE_COLLECTIONS_REQUEST,
  ANSIBLE_COLLECTIONS_SUCCESS,
  ANSIBLE_COLLECTIONS_ERROR,
} from './AnsibleCollectionsConstants';

const initialState = initialApiState;

export default (state = initialState, action) => {
  switch (action.type) {
  case ANSIBLE_COLLECTIONS_REQUEST: {
    return state.set('loading', true);
  }
  case ANSIBLE_COLLECTIONS_SUCCESS: {
    const {
      results, page, per_page, subtotal, // eslint-disable-line camelcase
    } = action.response;
    return state.merge({
      results,
      loading: false,
      pagination: {
        page: Number(page),
        perPage: Number(per_page || state.pagination.perPage), // eslint-disable-line camelcase
      },
      itemCount: Number(subtotal),
    });
  }
  case ANSIBLE_COLLECTIONS_ERROR: {
    return state.merge({
      error: action.error,
      loading: false,
    });
  }
  default: {
    return state;
  }
  }
};
