import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { HOST_DEBS_KEY } from './HostDebsConstants';

export const selectHostDebs = state =>
  selectAPIResponse(state, HOST_DEBS_KEY) || {};

export const selectHostDebsStatus = state =>
  selectAPIStatus(state, HOST_DEBS_KEY) || STATUS.PENDING;

export const selectHostDebsError = state =>
  selectAPIError(state, HOST_DEBS_KEY);
