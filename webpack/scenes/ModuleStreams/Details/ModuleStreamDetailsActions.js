import api from '../../../services/api';
import {
  MODULE_STREAM_DETAILS_REQUEST,
  MODULE_STREAM_DETAILS_SUCCESS,
  MODULE_STREAM_DETAILS_FAILURE,
} from './ModuleStreamDetailsConstants';
import { apiError } from '../../../move_to_foreman/common/helpers.js';

export const loadModuleStreamDetails = moduleStreamId => async (dispatch) => {
  dispatch({ type: MODULE_STREAM_DETAILS_REQUEST });

  try {
    const { data } = await api.get(`/module_streams/${moduleStreamId}`);
    return dispatch({
      type: MODULE_STREAM_DETAILS_SUCCESS,
      response: data,
    });
  } catch (error) {
    return dispatch(apiError(MODULE_STREAM_DETAILS_FAILURE, error));
  }
};

export default loadModuleStreamDetails;
