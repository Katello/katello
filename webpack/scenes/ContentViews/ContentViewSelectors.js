import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import CONTENT_VIEWS_KEY from './ContentViewsConstants';

export const selectContentViews = state =>
  selectAPIResponse(state, CONTENT_VIEWS_KEY) || {};

export const selectContentViewStatus = state =>
  selectAPIStatus(state, CONTENT_VIEWS_KEY) || STATUS.PENDING;

export const selectContentViewError = state =>
  selectAPIError(state, CONTENT_VIEWS_KEY);
