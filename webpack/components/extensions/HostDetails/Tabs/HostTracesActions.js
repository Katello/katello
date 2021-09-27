import { API_OPERATIONS, get, put } from 'foremanReact/redux/API';
import { HOST_TRACES_KEY, RESOLVE_HOST_TRACES_TASK_KEY, KATELLO_HOST_TOOLS_TRACER_KEY } from './HostTracesConstants';
import installPackage from './RemoteExecutionActions';
import { foremanApi } from '../../../../services/api';
import { getResponseErrorMsgs } from '../../../../utils/helpers';
import { renderTaskStartedToast } from '../../../../scenes/Tasks/helpers';

const errorToast = (error) => {
  const message = getResponseErrorMsgs(error.response);
  return message;
};

export const getHostTraces = (hostId, params) => get({
  type: API_OPERATIONS.GET,
  key: HOST_TRACES_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/traces`),
  params,
});

export const resolveHostTraces = (hostId, params) => put({
  type: API_OPERATIONS.PUT,
  key: RESOLVE_HOST_TRACES_TASK_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/traces/resolve`),
  handleSuccess: response => renderTaskStartedToast(response.data),
  errorToast: error => errorToast(error),
  params,
});

export const getTracerStatus = hostId => get({
  type: API_OPERATIONS.GET,
  key: KATELLO_HOST_TOOLS_TRACER_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/packages?search=name=katello-host-tools-tracer`),
});

export const installTracerPackage = ({ hostname }) => installPackage({
  hostname,
  packageName: 'katello-host-tools-tracer',
});
