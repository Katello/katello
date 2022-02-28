import Immutable from 'seamless-immutable';
import { isEmpty, get } from 'lodash';

import {
  REPOSITORY_SETS_REQUEST,
  REPOSITORY_SETS_SUCCESS,
  REPOSITORY_SETS_FAILURE,
  REPOSITORY_SETS_UPDATE_RECOMMENDED,
} from '../../consts';

import { initialState } from './sets.fixtures.js';

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
  case REPOSITORY_SETS_REQUEST:
    return state.set('loading', true);

  case REPOSITORY_SETS_UPDATE_RECOMMENDED:
    return state
      .set('recommended', payload);

  case REPOSITORY_SETS_SUCCESS:
    return state
      .set('results', payload.response.results)
      .set('pagination', {
        page: Number(payload.response.page),
        // server can return per_page: null when there's error in the search query,
        // don't store it in such case
        // eslint-disable-next-line camelcase
        perPage: Number(payload.response.per_page || state.pagination.perPage),
      })
      .set('itemCount', Number(payload.response.subtotal))
      .set('loading', false)
      .set('searchIsActive', !isEmpty(payload.search))
      .set('search', payload.search);

  case REPOSITORY_SETS_FAILURE:
    return Immutable({
      error: payload,
      loading: false,
      missingPermissions: get(payload, ['response', 'data', 'error', 'missing_permissions']),
    });

  default:
    return state;
  }
};
