import api, { foremanApi } from '../../../services/api';
import HOST_DETAILS_KEY, { ORGANIZATION, AVAILABLE_RELEASE_VERSIONS } from './HostDetailsConstants';

const hostIdNotReady = { type: 'NOOP_HOST_ID_NOT_READY' };

export const getHostDetails = ({ hostname }) => ({
  type: 'API_GET',
  payload: {
    key: HOST_DETAILS_KEY,
    url: `/api/hosts/${hostname}`,
  },
});

export const getOrganization = ({ orgId }) => ({
  type: 'API_GET',
  payload: {
    key: `${ORGANIZATION}_${orgId}`,
    url: api.getApiUrl(`/organizations/${orgId}`),
  },
});

export const getAvailableReleaseVersions = ({ hostId }) => ({
  type: 'API_GET',
  payload: {
    key: `${AVAILABLE_RELEASE_VERSIONS}_${hostId}`,
    url: foremanApi.getApiUrl(`/hosts/${hostId}/subscriptions/available_release_versions`),
  },
});

export default hostIdNotReady;
