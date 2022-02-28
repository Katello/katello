import Immutable from 'seamless-immutable';

import {
  ORGANIZATION_PRODUCTS_REQUEST,
  ORGANIZATION_PRODUCTS_SUCCESS,
  ORGANIZATION_PRODUCTS_FAILURE,
} from './OrganizationProductsConstants';

const initialState = Immutable({
  loading: false,
  error: null,
  results: [],
});

export default (state = initialState, action) => {
  const { type, payload } = action;

  switch (type) {
  case ORGANIZATION_PRODUCTS_REQUEST:
    return state.set('loading', true);

  case ORGANIZATION_PRODUCTS_SUCCESS:
    return state.merge({
      ...payload,
      loading: false,
    });

  case ORGANIZATION_PRODUCTS_FAILURE:
    return state.merge({
      error: payload,
      loading: false,
      results: [],
    });

  default:
    return state;
  }
};
