import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';

export const selectOrganization = (state, orgId) =>
  selectAPIResponse(state, `ORGANIZATION_${orgId}`) ?? {};

export const selectOrganizationStatus = (state, orgId) =>
  selectAPIStatus(state, `ORGANIZATION_${orgId}`) ?? STATUS.PENDING;

export const selectOrganizationError = (state, orgId) =>
  selectAPIError(state, `ORGANIZATION_${orgId}`);

export const selectAvailableReleaseVersions = (state, hostId) =>
  selectAPIResponse(state, `AVAILABLE_RELEASE_VERSIONS_${hostId}`) ?? {};

export const selectAvailableReleaseVersionsStatus = (state, hostId) =>
  selectAPIStatus(state, `AVAILABLE_RELEASE_VERSIONS_${hostId}`) ??
  STATUS.PENDING;

export const selectAvailableReleaseVersionsError = (state, hostId) =>
  selectAPIError(state, `AVAILABLE_RELEASE_VERSIONS_${hostId}`);
