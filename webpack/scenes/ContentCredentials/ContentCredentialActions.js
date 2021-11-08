import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import api, { orgId } from '../../services/api';
import { GET_CONTENT_CREDENTIALS_KEY } from './ContentCredentialConstants';

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

export default getContentCredentials;
