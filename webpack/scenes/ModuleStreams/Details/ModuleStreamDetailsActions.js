import api from '../../../services/api';
import {
  MODULE_STREAM_DETAILS_REQUEST,
  MODULE_STREAM_DETAILS_SUCCESS,
  MODULE_STREAM_DETAILS_FAILURE,
} from './ModuleStreamDetailsConstants';
import { apiError } from '../../../move_to_foreman/common/helpers.js';

export const loadModuleStreamDetails = moduleStreamId => (dispatch) => {
  dispatch({ type: MODULE_STREAM_DETAILS_REQUEST });

  return api
    .get(`/module_streams/${moduleStreamId}`)
    .then(({ data }) => {
      dispatch({
        type: MODULE_STREAM_DETAILS_SUCCESS,
        response: data,
      });
    })
    .catch((result) => {
      dispatch(apiError(MODULE_STREAM_DETAILS_FAILURE, result));
    });
};

export default loadModuleStreamDetails;
