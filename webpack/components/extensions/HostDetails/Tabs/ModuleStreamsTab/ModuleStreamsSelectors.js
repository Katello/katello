import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { MODULE_STREAMS_KEY } from './ModuleStreamsConstants';

export const selectModuleStream = state =>
  selectAPIResponse(state, MODULE_STREAMS_KEY) ?? {};

export const selectHostId = state =>
  selectAPIResponse(state, MODULE_STREAMS_KEY) ?? {};

export const selectModuleStreamStatus = state =>
  selectAPIStatus(state, MODULE_STREAMS_KEY) ?? STATUS.PENDING;

export const selecModuleStreamError = state =>
  selectAPIError(state, MODULE_STREAMS_KEY);
