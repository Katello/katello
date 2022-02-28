import { initialApiState } from '../../../services/api';
import {
  MODULE_STREAM_DETAILS_REQUEST,
  MODULE_STREAM_DETAILS_SUCCESS,
  MODULE_STREAM_DETAILS_FAILURE,
} from './ModuleStreamDetailsConstants';

export default (state = initialApiState, action) => {
  switch (action.type) {
  case MODULE_STREAM_DETAILS_REQUEST: {
    return state.set('loading', true);
  }

  case MODULE_STREAM_DETAILS_SUCCESS: {
    const moduleStreamDetails = action.response;

    return state.merge({
      ...moduleStreamDetails,
      loading: false,
    });
  }

  case MODULE_STREAM_DETAILS_FAILURE: {
    return state.merge({
      error: action.payload.message,
      loading: false,
    });
  }

  default:
    return state;
  }
};
