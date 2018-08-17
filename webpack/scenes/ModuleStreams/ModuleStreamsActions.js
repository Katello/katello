import api, { orgId } from '../../services/api';
import {
  MODULE_STREAMS_REQUEST,
  MODULE_STREAMS_SUCCESS,
  MODULE_STREAMS_FAILURE,
} from './ModuleStreamsConstants';
import { apiError } from '../../move_to_foreman/common/helpers.js';
import { propsToSnakeCase } from '../../services/index';

export const getModuleStreams = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: MODULE_STREAMS_REQUEST });

  const params = {
    organization_id: orgId(),
    ...propsToSnakeCase(extendedParams),
  };

  return api
    .get('/module_streams', {}, params)
    .then(({ data }) => {
      dispatch({
        type: MODULE_STREAMS_SUCCESS,
        response: data,
      });
    })
    .catch(result => dispatch(apiError(MODULE_STREAMS_FAILURE, result)));
};

export default getModuleStreams;
