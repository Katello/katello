import Immutable from 'seamless-immutable';

import { GET_TASK_SUCCESS } from '../../Tasks/TaskConstants';

import {
  UPLOAD_MANIFEST_REQUEST,
  UPLOAD_MANIFEST_SUCCESS,
  UPLOAD_MANIFEST_FAILURE,
  REFRESH_MANIFEST_REQUEST,
  REFRESH_MANIFEST_SUCCESS,
  REFRESH_MANIFEST_FAILURE,
  DELETE_MANIFEST_REQUEST,
  DELETE_MANIFEST_SUCCESS,
  DELETE_MANIFEST_FAILURE,
} from './ManifestConstants';

const initialState = Immutable({ pending: false });

export default (state = initialState, action) => {
  switch (action.type) {
    case UPLOAD_MANIFEST_REQUEST:
    case REFRESH_MANIFEST_REQUEST:
    case DELETE_MANIFEST_REQUEST:
      return state.set('pending', true).set('progress', 0);

    case UPLOAD_MANIFEST_SUCCESS:
    case REFRESH_MANIFEST_SUCCESS:
    case DELETE_MANIFEST_SUCCESS: {
      return state.merge(action.response);
    }

    case UPLOAD_MANIFEST_FAILURE:
    case REFRESH_MANIFEST_FAILURE:
    case DELETE_MANIFEST_FAILURE: {
      const error = action.result.response.data;
      return state.set('pending', false).set('error', error);
    }

    case GET_TASK_SUCCESS:
      // TODO check for task type
      return state.merge(action.response);

    default:
      return state;
  }
};
