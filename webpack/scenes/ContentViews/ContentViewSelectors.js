import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import CONTENT_VIEWS_KEY from './ContentViewsConstants';

export const selectContentViews = (state, index = '') => selectAPIResponse(state, CONTENT_VIEWS_KEY + index) || {};

export const selectContentViewStatus = (state, index = '') =>
  selectAPIStatus(state, CONTENT_VIEWS_KEY + index) || STATUS.PENDING;

export const selectContentViewError = (state, index = '') =>
  selectAPIError(state, CONTENT_VIEWS_KEY + index);
