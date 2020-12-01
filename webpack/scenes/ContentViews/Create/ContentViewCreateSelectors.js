import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { CREATE_CONTENT_VIEW_KEY } from '../ContentViewsConstants';

export const selectCreateContentViews = state =>
  selectAPIResponse(state, CREATE_CONTENT_VIEW_KEY) || {};

export const selectCreateContentViewStatus = state =>
  selectAPIStatus(state, CREATE_CONTENT_VIEW_KEY) || STATUS.PENDING;

export const selectCreateContentViewError = state =>
  selectAPIError(state, CREATE_CONTENT_VIEW_KEY);
