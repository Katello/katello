import { selectAPIError, selectAPIResponse, selectAPIStatus } from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import SYNC_STATUS_KEY, {
  SYNC_STATUS_POLL_KEY,
  SYNC_REPOSITORIES_KEY,
  CANCEL_SYNC_KEY,
} from './SyncStatusConstants';

export const selectSyncStatus = state =>
  selectAPIResponse(state, SYNC_STATUS_KEY) || {};

export const selectSyncStatusStatus = state =>
  selectAPIStatus(state, SYNC_STATUS_KEY) || STATUS.PENDING;

export const selectSyncStatusError = state =>
  selectAPIError(state, SYNC_STATUS_KEY);

export const selectSyncStatusPoll = state =>
  selectAPIResponse(state, SYNC_STATUS_POLL_KEY) || [];

export const selectSyncStatusPollStatus = state =>
  selectAPIStatus(state, SYNC_STATUS_POLL_KEY) || STATUS.PENDING;

export const selectSyncStatusPollError = state =>
  selectAPIError(state, SYNC_STATUS_POLL_KEY);

export const selectSyncRepositories = state =>
  selectAPIResponse(state, SYNC_REPOSITORIES_KEY) || [];

export const selectSyncRepositoriesStatus = state =>
  selectAPIStatus(state, SYNC_REPOSITORIES_KEY) || STATUS.PENDING;

export const selectSyncRepositoriesError = state =>
  selectAPIError(state, SYNC_REPOSITORIES_KEY);

export const selectCancelSync = state =>
  selectAPIResponse(state, CANCEL_SYNC_KEY) || {};

export const selectCancelSyncStatus = state =>
  selectAPIStatus(state, CANCEL_SYNC_KEY) || STATUS.PENDING;

export const selectCancelSyncError = state =>
  selectAPIError(state, CANCEL_SYNC_KEY);
