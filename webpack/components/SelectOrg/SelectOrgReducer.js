import Immutable from 'seamless-immutable';
import {
  GET_ORGANIZATIONS_LIST_SUCCESS,
  GET_ORGANIZATIONS_LIST_REQUEST,
  GET_ORGANIZATIONS_LIST_FAILURE,
  CHANGE_CURRENT_ORGANIZATION_SUCCESS,
} from '../../redux/consts';

const initialState = Immutable({ loading: false });
export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
  case GET_ORGANIZATIONS_LIST_REQUEST:
    return state.set('loading', true);

  case GET_ORGANIZATIONS_LIST_SUCCESS:
    return state
      .set('list', payload.results)
      .set('loading', false);

  case CHANGE_CURRENT_ORGANIZATION_SUCCESS:
    return state
      .set('currentId', payload)
      .set('loading', false);

  case GET_ORGANIZATIONS_LIST_FAILURE:
    return state
      .set('error', payload);
  default:
    return state;
  }
};
