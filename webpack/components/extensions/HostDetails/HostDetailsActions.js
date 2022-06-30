import { translate as __ } from 'foremanReact/common/I18n';
import { API_OPERATIONS, get, put } from 'foremanReact/redux/API';
import api, { foremanApi } from '../../../services/api';
import HOST_DETAILS_KEY, { ORGANIZATION, AVAILABLE_RELEASE_VERSIONS } from './HostDetailsConstants';
import { errorToast } from '../../../scenes/Tasks/helpers';

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

export const updateSystemPurposeAttributes = ({ hostId, attributes, refreshHostDetails }) => put({
  type: API_OPERATIONS.PUT,
  key: HOST_DETAILS_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}`),
  params: {
    id: hostId,
    host: {
      subscription_facet_attributes: attributes,
    },
  },
  successToast: () => __('System purpose attributes updated'),
  errorToast,
  handleSuccess: refreshHostDetails,
});


export default hostIdNotReady;
