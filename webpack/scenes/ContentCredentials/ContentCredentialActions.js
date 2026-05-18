import { API_OPERATIONS, get, post, APIActions } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import api, { orgId } from '../../services/api';
import { getResponseErrorMsgs } from '../../utils/helpers';
import {
  GET_CONTENT_CREDENTIALS_KEY,
  CREATE_CONTENT_CREDENTIAL_KEY,
  DELETE_CONTENT_CREDENTIAL_KEY,
} from './ContentCredentialConstants';

export const getContentCredentials = (params = {}) => {
  const defaultParams = {
    organization_id: orgId(),
  };

  return get({
    type: API_OPERATIONS.GET,
    key: GET_CONTENT_CREDENTIALS_KEY,
    url: api.getApiUrl('/content_credentials'),
    params: { ...defaultParams, ...params },
  });
};

export const createContentCredential = (params, handleSuccess) =>
  post({
    type: API_OPERATIONS.POST,
    key: CREATE_CONTENT_CREDENTIAL_KEY,
    url: api.getApiUrl('/content_credentials'),
    params,
    handleSuccess,
    successToast: response =>
      __('Content credential %s created').replace('%s', response.data.name),
    errorToast: error => getResponseErrorMsgs(error.response),
  });

export const deleteContentCredential = (id, handleSuccess) =>
  APIActions.delete({
    type: API_OPERATIONS.DELETE,
    key: DELETE_CONTENT_CREDENTIAL_KEY,
    url: api.getApiUrl(`/content_credentials/${id}`),
    handleSuccess,
    successToast: () => __('Content credential deleted'),
    errorToast: error => getResponseErrorMsgs(error.response),
  });

export default getContentCredentials;
