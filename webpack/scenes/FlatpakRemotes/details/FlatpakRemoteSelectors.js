import { selectAPIResponse, selectAPIStatus, selectAPIError } from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { getFlatpakRemoteDetailsKey } from './FlatpakRemoteConstants';

export const selectFlatpakRemoteDetails = (state, index) =>
  selectAPIResponse(state, getFlatpakRemoteDetailsKey(index)) || {};

export const selectFlatpakRemoteStatus = (state, index) =>
  selectAPIStatus(state, getFlatpakRemoteDetailsKey(index)) || STATUS.PENDING;

export const selectFlatpakRemoteError = (state, index) =>
  selectAPIError(state, getFlatpakRemoteDetailsKey(index));
