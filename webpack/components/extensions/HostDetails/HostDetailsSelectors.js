import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import HOST_DETAILS_KEY from './HostDetailsConstants';

export const selectHostDetails = state =>
  selectAPIResponse(state, HOST_DETAILS_KEY) || {};

export const selectHostDetailsStatus = state =>
  selectAPIStatus(state, HOST_DETAILS_KEY) || STATUS.PENDING;

export const selectHostDetailsError = state =>
  selectAPIError(state, HOST_DETAILS_KEY);

export const selectHostDetailsState = state =>
  state.katello.hostDetails;

export const selectHostDetailsClearSearch = state =>
  selectHostDetailsState(state).clearSearch;
