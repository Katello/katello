import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { cvVersionPublishKey } from '../ContentViewsConstants';

export const selectPublishContentViews = (state, cvId, versionCount) =>
  selectAPIResponse(state, cvVersionPublishKey(cvId, versionCount)) || {};

export const selectPublishContentViewStatus = (state, cvId, versionCount) =>
  selectAPIStatus(state, cvVersionPublishKey(cvId, versionCount)) || STATUS.PENDING;

export const selectPublishContentViewsError = (state, cvId, versionCount) =>
  selectAPIError(state, cvVersionPublishKey(cvId, versionCount));

