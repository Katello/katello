import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { HOST_INSTALLABLE_DEBS_KEY } from './InstallableDebsConstants';

export const selectHostInstallableDebs = state =>
  selectAPIResponse(state, HOST_INSTALLABLE_DEBS_KEY) || {};

export const selectHostInstallableDebsStatus = state =>
  selectAPIStatus(state, HOST_INSTALLABLE_DEBS_KEY) || STATUS.PENDING;

export const selectHostInstallableDebsError = state =>
  selectAPIError(state, HOST_INSTALLABLE_DEBS_KEY);
