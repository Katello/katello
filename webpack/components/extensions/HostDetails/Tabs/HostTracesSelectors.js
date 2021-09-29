import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { HOST_TRACES_KEY } from './HostTracesConstants';

export const selectHostTraces = state =>
  selectAPIResponse(state, HOST_TRACES_KEY) ?? {};

export const selectHostId = state =>
  selectAPIResponse(state, HOST_TRACES_KEY) ?? {};

export const selectHostTracesStatus = state =>
  selectAPIStatus(state, HOST_TRACES_KEY) ?? STATUS.PENDING;

export const selectHostTracesError = state =>
  selectAPIError(state, HOST_TRACES_KEY);
