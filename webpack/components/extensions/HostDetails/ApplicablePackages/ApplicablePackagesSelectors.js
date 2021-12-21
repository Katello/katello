import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { HOST_APPLICABLE_PACKAGES_KEY } from './ApplicablePackagesConstants';

export const selectHostApplicablePackages = state =>
  selectAPIResponse(state, HOST_APPLICABLE_PACKAGES_KEY) || {};

export const selectHostApplicablePackagesStatus = state =>
  selectAPIStatus(state, HOST_APPLICABLE_PACKAGES_KEY) || STATUS.PENDING;

export const selectHostApplicablePackagesError = state =>
  selectAPIError(state, HOST_APPLICABLE_PACKAGES_KEY);
