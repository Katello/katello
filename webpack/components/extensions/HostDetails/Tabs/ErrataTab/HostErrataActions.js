import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import { foremanApi } from '../../../../../services/api';
import { HOST_ERRATA_KEY } from './HostErrataConstants';

export const getInstallableErrata = (hostId, params) => get({
  type: API_OPERATIONS.GET,
  key: HOST_ERRATA_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/errata`),
  params,
});

export default getInstallableErrata;

