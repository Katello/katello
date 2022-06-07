import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import api, { foremanApi, orgId } from '../../services/api';
import SMART_PROXY_CONTENT_KEY, { SMART_PROXY_KEY } from './SmartProxyContentConstants';

const getSmartProxyContent = ({ smartProxyId }) => get({
  type: API_OPERATIONS.GET,
  key: SMART_PROXY_CONTENT_KEY,
  url: api.getApiUrl(`/capsules/${smartProxyId}/content/sync?${orgId()}`),
});

export const getSmartProxies = () => get({
  type: API_OPERATIONS.GET,
  key: SMART_PROXY_KEY,
  url: foremanApi.getApiUrl('/smart_proxies'),
  params: { organization_id: orgId(), per_page: 'all' },
});

export default getSmartProxyContent;
