import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { HOST_TRACES_KEY, KATELLO_HOST_TOOLS_TRACER_KEY } from './HostTracesConstants';

export const selectHostTraces = state =>
  selectAPIResponse(state, HOST_TRACES_KEY) ?? {};

export const selectHostId = state =>
  selectAPIResponse(state, HOST_TRACES_KEY) ?? {};

export const selectHostTracesStatus = state =>
  selectAPIStatus(state, HOST_TRACES_KEY) ?? STATUS.PENDING;

export const selectHostTracesError = state =>
  selectAPIError(state, HOST_TRACES_KEY);

export const selectKatelloHostToolsTracer = state =>
  selectAPIResponse(state, KATELLO_HOST_TOOLS_TRACER_KEY);

export const selectIsTracerInstalled = (state) => {
  const tracerResults = selectKatelloHostToolsTracer(state)?.results;
  return !!(tracerResults?.length && tracerResults[0].name === 'katello-host-tools-tracer');
};
