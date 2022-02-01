import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import katelloApi from '../../../../services/api';
import { HOST_YUM_INSTALLABLE_PACKAGES_KEY } from './YumInstallablePackagesConstants';

export const getHostYumInstallablePackages = (hostId, params) => get({
  type: API_OPERATIONS.GET,
  key: HOST_YUM_INSTALLABLE_PACKAGES_KEY,
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

