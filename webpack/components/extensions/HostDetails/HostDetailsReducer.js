import Immutable from 'seamless-immutable';

import { SET_CLEAR_SEARCH } from './HostDetailsConstants';

const initialState = Immutable({ clearSearch: undefined });

export default (state = initialState, action) => {
  switch (action.type) {
  case SET_CLEAR_SEARCH:
    return state.set('clearSearch', action.payload);
  default:
    return state;
  }
};
