import { API_OPERATIONS, get, post } from 'foremanReact/redux/API';
import { HOST_TRACES_KEY} from './HostTracesConstants';
import { foremanApi } from '../../../../services/api';

const getHostTraces = (hostId) => get({
  type: API_OPERATIONS.GET,
  key: HOST_TRACES_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/traces`),
});

export default getHostTraces;
