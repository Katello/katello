import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { HOST_ERRATA_KEY } from './HostErrataConstants';

export const selectHostErrata = state =>
  selectAPIResponse(state, HOST_ERRATA_KEY) || {};

export const selectHostErrataStatus = state =>
  selectAPIStatus(state, HOST_ERRATA_KEY) || STATUS.PENDING;

export const selectHostErrataError = state =>
  selectAPIError(state, HOST_ERRATA_KEY);
