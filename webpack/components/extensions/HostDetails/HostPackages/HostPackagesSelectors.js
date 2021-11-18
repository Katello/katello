import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { HOST_PACKAGES_KEY } from './HostPackagesConstants';

export const selectHostPackages = state =>
  selectAPIResponse(state, HOST_PACKAGES_KEY) || {};

export const selectHostPackagesStatus = state =>
  selectAPIStatus(state, HOST_PACKAGES_KEY) || STATUS.PENDING;

export const selectHostPackagesError = state =>
  selectAPIError(state, HOST_PACKAGES_KEY);
