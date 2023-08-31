import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import katelloApi from '../../../../../services/api';
import { HOST_INSTALLABLE_DEBS_KEY } from './InstallableDebsConstants';

export const getHostInstallableDebs = (hostId, params) => get({
  type: API_OPERATIONS.GET,
  key: HOST_INSTALLABLE_DEBS_KEY,
  url: katelloApi.getApiUrl('/debs'),
  params: {
    ...params,
    host_id: hostId,
    packages_restrict_not_installed: true,
    packages_restrict_applicable: false,
  },
});
export default getHostInstallableDebs;

