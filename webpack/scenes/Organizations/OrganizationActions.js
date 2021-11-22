import { translate as __ } from 'foremanReact/common/I18n';
import { propsToSnakeCase } from 'foremanReact/common/helpers';
import { API_OPERATIONS, put } from 'foremanReact/redux/API';

import api, { orgId } from '../../services/api';

import {
  GET_ORGANIZATION_REQUEST,
  GET_ORGANIZATION_SUCCESS,
  GET_ORGANIZATION_FAILURE,
  UPDATE_CDN_CONFIGURATION_KEY,
} from './OrganizationConstants';
import { getResponseErrorMsgs } from '../../utils/helpers';

export const loadOrganization = (extendedParams = {}) => async (dispatch) => {
  dispatch({ type: GET_ORGANIZATION_REQUEST });

  const params = {
    ...propsToSnakeCase(extendedParams),
  };

  try {
    const { data } = await api.get(`/organizations/${orgId()}`, {}, params);
    return dispatch({
      type: GET_ORGANIZATION_SUCCESS,
      response: data,
    });
  } catch (error) {
    return dispatch({
      type: GET_ORGANIZATION_FAILURE,
      error,
    });
  }
};

const updateCdnConfigurationSuccessToast = () => __('CDN Configuration updated.');
const updateCdnConfigurationErrorToast = (error) => {
  const messages = getResponseErrorMsgs(error.response);
  return messages;
};

export const updateCdnConfiguration = (params, updateResults, onError) => {
  const nonNullParams = Object.keys(params)
    .filter(key => params[key] !== null)
    .reduce((a, k) => ({ ...a, [k]: params[k] }), {});

  return put({
    type: API_OPERATIONS.PUT,
    key: UPDATE_CDN_CONFIGURATION_KEY,
    url: api.getApiUrl(`/organizations/${orgId()}/cdn_configuration`),
    params: nonNullParams,
    errorToast: error => updateCdnConfigurationErrorToast(error),
    successToast: response => updateCdnConfigurationSuccessToast(response),
    updateData: (_, resp) => {
      updateResults(resp);
    },
    handleError: onError,
  });
};

export default loadOrganization;
