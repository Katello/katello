import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import SMART_PROXY_CONTENT_KEY from './SmartProxyContentConstants';

export const selectSmartProxyContent = state =>
  selectAPIResponse(state, SMART_PROXY_CONTENT_KEY) || {};

export const selectSmartProxyContentStatus = state =>
  selectAPIStatus(state, SMART_PROXY_CONTENT_KEY) || STATUS.PENDING;

export const selectSmartProxyContentError = state =>
  selectAPIError(state, SMART_PROXY_CONTENT_KEY);
