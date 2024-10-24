import { API_OPERATIONS, get, post } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import api, { foremanApi, orgId } from '../../services/api';
import SMART_PROXY_CONTENT_KEY, { SMART_PROXY_COUNTS_UPDATE_KEY, SMART_PROXY_KEY } from './SmartProxyContentConstants';
import { renderTaskStartedToast } from '../Tasks/helpers';
import { getResponseErrorMsgs } from '../../utils/helpers';

const getSmartProxyContent = ({ smartProxyId, organizationId }) => get({
  type: API_OPERATIONS.GET,
  key: SMART_PROXY_CONTENT_KEY,
  url: api.getApiUrl(organizationId ? `/capsules/${smartProxyId}/content/sync?organization_id=${organizationId}` : `/capsules/${smartProxyId}/content/sync`),
});

export const getSmartProxies = () => get({
  type: API_OPERATIONS.GET,
  key: SMART_PROXY_KEY,
  url: foremanApi.getApiUrl('/smart_proxies'),
  params: { organization_id: orgId(), per_page: 'all' },
});

export const updateSmartProxyContentCounts = (smartProxyId, params) => post({
  type: API_OPERATIONS.POST,
  key: SMART_PROXY_COUNTS_UPDATE_KEY,
  url: api.getApiUrl(`/capsules/${smartProxyId}/content/update_counts`),
  params,
  handleSuccess: (response) => {
    renderTaskStartedToast(response?.data, __('Smart proxy content count refresh has started in the background'));
  },
  errorToast: error => __(`Something went wrong while refreshing content counts: ${getResponseErrorMsgs(error.response)}`),
});

export default getSmartProxyContent;
