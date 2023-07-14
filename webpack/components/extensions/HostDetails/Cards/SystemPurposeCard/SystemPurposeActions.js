import { translate as __ } from 'foremanReact/common/I18n';
import { API_OPERATIONS, put } from 'foremanReact/redux/API';
import api, { foremanApi } from '../../../../../services/api';
import HOST_DETAILS_KEY from '../../HostDetailsConstants';
import { ACTIVATION_KEY } from '../../../../../scenes/ActivationKeys/Details/ActivationKeyConstants';
import { ORGANIZATION, AVAILABLE_RELEASE_VERSIONS, RELEASES } from './SystemPurposeConstants';
import { errorToast } from '../../../../../scenes/Tasks/helpers';

export const getOrganization = ({ orgId }) => ({
  type: 'API_GET',
  payload: {
    key: `${ORGANIZATION}_${orgId}`,
    url: api.getApiUrl(`/organizations/${orgId}`),
  },
});

export const getHostAvailableReleaseVersions = ({ hostId }) => ({
  type: 'API_GET',
  payload: {
    key: `${AVAILABLE_RELEASE_VERSIONS}_${hostId}`,
    url: foremanApi.getApiUrl(`/hosts/${hostId}/subscriptions/available_release_versions`),
  },
});

export const getAKAvailableReleaseVersions = ({ id }) => ({
  type: API_OPERATIONS.GET,
  payload: {
    key: `${RELEASES}_${id}`,
    url: api.getApiUrl(`/activation_keys/${id}/releases`),
  },
});

export const updateHostSysPurposeAttributes = ({ id, attributes, refreshHostDetails }) => put({
  type: API_OPERATIONS.PUT,
  key: HOST_DETAILS_KEY,
  url: foremanApi.getApiUrl(`/hosts/${id}`),
  params: {
    id,
    host: {
      subscription_facet_attributes: attributes,
    },
  },
  successToast: () => __('System purpose attributes updated'),
  errorToast,
  handleSuccess: refreshHostDetails,
});

export const updateAKSysPurposeAttributes = ({ id, attributes, refreshAKDetails }) => put({
  type: API_OPERATIONS.PUT,
  key: ACTIVATION_KEY,
  url: api.getApiUrl(`/activation_keys/${id}`),
  params: {
    id,
    activation_key: attributes,
  },
  successToast: () => __('System purpose attributes updated'),
  errorToast,
  handleSuccess: refreshAKDetails,
});
