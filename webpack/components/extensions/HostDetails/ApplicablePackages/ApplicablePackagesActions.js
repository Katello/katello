import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import katelloApi from '../../../../services/api';
import { HOST_APPLICABLE_PACKAGES_KEY } from './ApplicablePackagesConstants';

export const getHostYumInstallablePackages = (hostId, params) => get({
  type: API_OPERATIONS.GET,
  key: HOST_APPLICABLE_PACKAGES_KEY,
  url: katelloApi.getApiUrl('/packages'),
  params: {
    ...params,
    host_id: hostId,
    packages_restrict_not_installed: true,
    packages_restrict_applicable: false,
    packages_restrict_latest: true,
  },
});
export default getHostYumInstallablePackages;

