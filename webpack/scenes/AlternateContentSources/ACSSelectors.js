import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import ACS_KEY, { CREATE_ACS_KEY } from './ACSConstants';

export const selectAlternateContentSources = (state, index = '') => selectAPIResponse(state, ACS_KEY + index) || {};

export const selectAlternateContentSourcesStatus = (state, index = '') =>
  selectAPIStatus(state, ACS_KEY + index) || STATUS.PENDING;

export const selectAlternateContentSourcesError = (state, index = '') =>
  selectAPIError(state, ACS_KEY + index);

export const selectCreateACS = state =>
  selectAPIResponse(state, CREATE_ACS_KEY) || {};

export const selectCreateACSStatus = state =>
  selectAPIStatus(state, CREATE_ACS_KEY) || STATUS.PENDING;

export const selectCreateACSError = state =>
  selectAPIError(state, CREATE_ACS_KEY);
