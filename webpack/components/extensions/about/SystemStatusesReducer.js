import Immutable from 'seamless-immutable';
import {
  SYSTEM_STATUSES_FAILURE,
  SYSTEM_STATUSES_SUCCESS,
  SYSTEM_STATUSES_REQUEST,
} from './SystemStatusesConsts';

const initialState = Immutable({
  services: {},
  loaderStatus: '',
});

export default (state = initialState, action) => {
  switch (action.type) {
  case SYSTEM_STATUSES_REQUEST:
    return state.set('loaderStatus', 'PENDING');
  case SYSTEM_STATUSES_SUCCESS:
    return state
      .set('services', action.payload.services)
      .set('loaderStatus', 'RESOLVED');
  case SYSTEM_STATUSES_FAILURE:
    return state.set('loaderStatus', 'ERROR');
  default:
    return state;
  }
};
