import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { COPY_CONTENT_VIEW_KEY } from '../ContentViewsConstants';

export const selectCopyContentViews = state =>
  selectAPIResponse(state, COPY_CONTENT_VIEW_KEY) || {};

export const selectCopyContentViewStatus = state =>
  selectAPIStatus(state, COPY_CONTENT_VIEW_KEY) || STATUS.PENDING;

export const selectCopyContentViewError = state =>
  selectAPIError(state, COPY_CONTENT_VIEW_KEY);
