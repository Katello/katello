import { API_OPERATIONS, get, put } from 'foremanReact/redux/API';
import api, { foremanApi } from '../../../../../services/api';
import { ALTER_HOST_HOST_COLLECTIONS_KEY, AVAILABLE_HOST_COLLECTIONS_KEY, REMOVABLE_HOST_COLLECTIONS_KEY } from './HostCollectionsConstants';

export const getHostAvailableHostCollections = params => get({
  type: API_OPERATIONS.GET,
  key: AVAILABLE_HOST_COLLECTIONS_KEY,
  url: api.getApiUrl('/host_collections?available_for=host'),
  params,
});

export const getHostRemovableHostCollections = params => get({
  type: API_OPERATIONS.GET,
  key: REMOVABLE_HOST_COLLECTIONS_KEY,
  url: api.getApiUrl('/host_collections'),
  params,
});

export const alterHostCollections = (hostId, params) => put({
  type: API_OPERATIONS.PUT,
  key: ALTER_HOST_HOST_COLLECTIONS_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/host_collections`),
  params,
});

