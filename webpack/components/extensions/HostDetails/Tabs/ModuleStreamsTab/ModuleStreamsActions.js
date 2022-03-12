import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import { errorToast } from '../../../../../scenes/Tasks/helpers';
import { foremanApi } from '../../../../../services/api';
import { MODULE_STREAMS_KEY } from './ModuleStreamsConstants';

export const getHostModuleStreams = (hostId, params) => get({
  type: API_OPERATIONS.GET,
  key: MODULE_STREAMS_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/module_streams`),
  errorToast: error => errorToast(error),
  params,
});

export default getHostModuleStreams;
