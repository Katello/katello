import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import { foremanApi } from '../../../../services/api';
import { HOST_PACKAGES_KEY } from './HostPackagesConstants';

export const getInstalledPackagesWithLatest = (hostId, params) => get({
  type: API_OPERATIONS.GET,
  key: HOST_PACKAGES_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/packages?include_latest_upgradable=true`),
  params,
});
export default getInstalledPackagesWithLatest;
