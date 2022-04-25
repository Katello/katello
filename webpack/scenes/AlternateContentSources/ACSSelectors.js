import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import ACS_KEY from './ACSConstants';

export const selectAlternateContentSources = (state, index = '') => selectAPIResponse(state, ACS_KEY + index) || {};

export const selectAlternateContentSourcesStatus = (state, index = '') =>
  selectAPIStatus(state, ACS_KEY + index) || STATUS.PENDING;

export const selectAlternateContentSourcesError = (state, index = '') =>
  selectAPIError(state, ACS_KEY + index);
