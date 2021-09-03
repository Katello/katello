import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import api from '../../services/api';
import { CONTENT_KEY, CONTENT_TYPES_KEY } from './ContentConstants';

export const getContent = (contentType, params) => get({
  type: API_OPERATIONS.GET,
  key: CONTENT_KEY,
  params,
  url: api.getApiUrl(`/${contentType}`),
});

export const getContentTypes = () => get({
  type: API_OPERATIONS.GET,
  key: CONTENT_TYPES_KEY,
  url: api.getApiUrl('/repositories/content_types'),
});

export default getContent;
