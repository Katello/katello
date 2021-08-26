import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import { HOST_TRACES_KEY } from './HostTracesConstants';
import { foremanApi } from '../../../../services/api';

const getHostTraces = (hostId, params) => get({
  type: API_OPERATIONS.GET,
  key: HOST_TRACES_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/traces`),
  params,
});

export default getHostTraces;
