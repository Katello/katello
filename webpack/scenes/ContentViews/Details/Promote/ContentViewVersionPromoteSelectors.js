import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { cvVersionPromoteKey } from '../../ContentViewsConstants';

export const selectPromoteCVVersionResponse = (state, versionId, versionEnvironments) =>
  selectAPIResponse(state, cvVersionPromoteKey(versionId, versionEnvironments)) || {};

export const selectPromoteCVVersionStatus = (state, versionId, versionEnvironments) =>
  selectAPIStatus(state, cvVersionPromoteKey(versionId, versionEnvironments)) || STATUS.PENDING;

export const selectPromoteCVVersionError = (state, versionId, versionEnvironments) =>
  selectAPIError(state, cvVersionPromoteKey(versionId, versionEnvironments));
