import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import { foremanApi } from '../../../../../services/api';
import {
  HOST_DEBS_KEY,
} from './HostDebsConstants';

export const getInstalledDebs = (hostId, params) => get({
  type: API_OPERATIONS.GET,
  key: HOST_DEBS_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/debs?include_latest_upgradable=true`),
  params,
});
export default getInstalledDebs;
