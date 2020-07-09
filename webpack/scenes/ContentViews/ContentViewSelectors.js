import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import CONTENT_VIEWS_KEY from './ContentViewsConstants';

export const selectContentViews = state => selectAPIResponse(state, CONTENT_VIEWS_KEY) || {};

export const selectContentViewStatus = state => selectAPIStatus(state, CONTENT_VIEWS_KEY);

export const selectContentViewError = state => selectAPIError(state, CONTENT_VIEWS_KEY);
