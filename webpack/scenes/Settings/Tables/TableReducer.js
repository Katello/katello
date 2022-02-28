import Immutable from 'seamless-immutable';
import { mapTables } from './TableHelpers';
import {
  TABLES_REQUEST,
  TABLES_SUCCESS,
  TABLES_FAILURE,
  CREATE_TABLE,
  CREATE_TABLE_SUCCESS,
  CREATE_TABLE_FAILURE,
  UPDATE_TABLE,
  UPDATE_TABLE_SUCCESS,
  UPDATE_TABLE_FAILURE,
} from './TableConstants';

const initialState = Immutable({
  loading: false,
});

export default (state = initialState, action) => {
  switch (action.type) {
  case TABLES_REQUEST:
  case CREATE_TABLE:
  case UPDATE_TABLE:
    return state.set('loading', true);

  case TABLES_SUCCESS:
    return state.merge({
      loading: false,
      ...mapTables(action.payload.results),
    });
  case CREATE_TABLE_SUCCESS:
  case UPDATE_TABLE_SUCCESS:
    return state.merge({
      loading: false,
      ...state,
      ...mapTables(action.payload),
    });
  case TABLES_FAILURE:
  case UPDATE_TABLE_FAILURE:
  case CREATE_TABLE_FAILURE: {
    return state.set('loading', false);
  }
  default:
    return state;
  }
};
