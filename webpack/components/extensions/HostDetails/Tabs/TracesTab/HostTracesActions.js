import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import {
  HOST_TRACES_KEY,
  KATELLO_TRACER_PACKAGE,
} from './HostTracesConstants';
import { installPackage } from '../RemoteExecutionActions';
import { foremanApi } from '../../../../../services/api';

export const getHostTraces = (hostId, params) => get({
  type: API_OPERATIONS.GET,
  key: HOST_TRACES_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/traces`),
  params,
});

export const installTracerPackage = ({ hostname, handleSuccess }) => installPackage({
  hostname,
  packageName: KATELLO_TRACER_PACKAGE,
  handleSuccess,
});
