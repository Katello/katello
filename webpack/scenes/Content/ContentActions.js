import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import api from '../../services/api';
import { CONTENT_KEY, CONTENT_TYPES_KEY, CONTENT_ID_KEY, REPOSITORY_CONTENT_ID_KEY } from './ContentConstants';

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

export const getContentDetails = (contentType, id) => get({
  type: API_OPERATIONS.GET,
  key: CONTENT_ID_KEY,
  url: api.getApiUrl(`/${contentType}/${id}`),
});

export const getRepositoryContentDetails = (contentType, id, params) => get({
  type: API_OPERATIONS.GET,
  key: REPOSITORY_CONTENT_ID_KEY,
  params,
  url: api.getApiUrl(`/repositories?${contentType}_id=${id}`),
});

export default getContent;
