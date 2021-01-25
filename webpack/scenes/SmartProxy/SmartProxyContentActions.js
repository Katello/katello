import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import api, { orgId } from '../../services/api';
import SMART_PROXY_CONTENT_KEY from './SmartProxyContentConstants';

const getSmartProxyContent = ({ smartProxyId }) => get({
  type: API_OPERATIONS.GET,
  key: SMART_PROXY_CONTENT_KEY,
  url: api.getApiUrl(`/capsules/${smartProxyId}/content/sync?${orgId()}`),
});

export default getSmartProxyContent;
