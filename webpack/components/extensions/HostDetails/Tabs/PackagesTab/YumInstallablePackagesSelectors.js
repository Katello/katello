import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { HOST_YUM_INSTALLABLE_PACKAGES_KEY } from './YumInstallablePackagesConstants';

export const selectHostYumInstallablePackages = state =>
  selectAPIResponse(state, HOST_YUM_INSTALLABLE_PACKAGES_KEY) || {};

export const selectHostYumInstallablePackagesStatus = state =>
  selectAPIStatus(state, HOST_YUM_INSTALLABLE_PACKAGES_KEY) || STATUS.PENDING;

export const selectHostYumInstallablePackagesError = state =>
  selectAPIError(state, HOST_YUM_INSTALLABLE_PACKAGES_KEY);
