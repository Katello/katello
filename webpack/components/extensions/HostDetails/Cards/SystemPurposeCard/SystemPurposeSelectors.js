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

export const selectAvailableReleaseVersions = (state, id, key = 'AVAILABLE_RELEASE_VERSIONS') =>
  selectAPIResponse(state, `${key}_${id}`) ?? {};

export const selectAvailableReleaseVersionsStatus = (state, id, key = 'AVAILABLE_RELEASE_VERSIONS') =>
  selectAPIStatus(state, `${key}_${id}`) ??
  STATUS.PENDING;

export const selectAvailableReleaseVersionsError = (state, id, key = 'AVAILABLE_RELEASE_VERSIONS') =>
  selectAPIError(state, `${key}_${id}`);

