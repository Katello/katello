import { propsToSnakeCase } from 'foremanReact/common/helpers';

import api, { orgId } from '../../services/api';
import {
  MODULE_STREAMS_REQUEST,
  MODULE_STREAMS_SUCCESS,
  MODULE_STREAMS_FAILURE,
} from './ModuleStreamsConstants';
import { apiError } from '../../utils/helpers.js';

export const getModuleStreams = (extendedParams = {}) => async (dispatch) => {
  dispatch({ type: MODULE_STREAMS_REQUEST });

  const params = {
    organization_id: orgId(),
    ...propsToSnakeCase(extendedParams),
  };
  try {
    const { data } = await api.get('/module_streams', {}, params);
    return dispatch({
      type: MODULE_STREAMS_SUCCESS,
      response: data,
    });
  } catch (error) {
    return dispatch(apiError(MODULE_STREAMS_FAILURE, error));
  }
};

export default getModuleStreams;
