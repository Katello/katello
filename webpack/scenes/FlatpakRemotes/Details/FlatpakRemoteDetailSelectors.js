import { STATUS } from 'foremanReact/constants';
import {
  selectAPIError,
  selectAPIResponse,
  selectAPIStatus,
} from 'foremanReact/redux/API/APISelectors';
import { flatpakRemoteDetailsKey } from '../FlatpakRemotesConstants';

export const selectFlatpakRemoteDetails = (state, id) =>
  selectAPIResponse(state, flatpakRemoteDetailsKey(id)) || {};

export const selectFlatpakRemoteDetailStatus =
  (state, id) => selectAPIStatus(state, flatpakRemoteDetailsKey(id)) || STATUS.PENDING;

export const selectFlatpakRemoteDetailError =
  (state, id) => selectAPIError(state, flatpakRemoteDetailsKey(id));
