import Immutable from 'seamless-immutable';

import { initialApiState } from '../../services/api';

import {
  CONTENT_VIEWS_REQUEST,
  CONTENT_VIEWS_SUCCESS,
  CONTENT_VIEWS_FAILURE,
} from './ContentViewConstants';

const initialState = Immutable({
  ...initialApiState,
});

export default (state = initialState, action) => {
  switch (action.type) {
    case CONTENT_VIEWS_REQUEST:
      return state.set('loading', true);

    case CONTENT_VIEWS_SUCCESS: {
      return state.merge({
        index: action.response,
      });
    };

    case CONTENT_VIEWS_FAILURE:
      return state
        .set('loading', false)
        .set('results', []);

    default:
      return state;
  };
};
