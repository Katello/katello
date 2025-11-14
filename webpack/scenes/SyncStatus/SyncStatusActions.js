import { API_OPERATIONS, get, post, APIActions } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import api, { orgId } from '../../services/api';
import SYNC_STATUS_KEY, {
  SYNC_STATUS_POLL_KEY,
  SYNC_REPOSITORIES_KEY,
  CANCEL_SYNC_KEY,
} from './SyncStatusConstants';
import { getResponseErrorMsgs } from '../../utils/helpers';

export const syncStatusErrorToast = (error) => {
  const message = getResponseErrorMsgs(error.response);
  return message;
};

export const getSyncStatus = (extraParams = {}) => get({
  type: API_OPERATIONS.GET,
  key: SYNC_STATUS_KEY,
  url: api.getApiUrl('/sync_status'),
  params: {
    organization_id: orgId(),
    ...extraParams,
  },
  errorToast: error => syncStatusErrorToast(error),
});

export const pollSyncStatus = (repositoryIds, extraParams = {}) => get({
  type: API_OPERATIONS.GET,
  key: SYNC_STATUS_POLL_KEY,
  url: api.getApiUrl('/sync_status/poll'),
  params: {
    repository_ids: repositoryIds,
    organization_id: orgId(),
    ...extraParams,
  },
  errorToast: error => syncStatusErrorToast(error),
});

export const syncRepositories = (repositoryIds, handleSuccess, handleError) => post({
  type: API_OPERATIONS.POST,
  key: SYNC_REPOSITORIES_KEY,
  url: api.getApiUrl('/sync_status/sync'),
  params: {
    repository_ids: repositoryIds,
    organization_id: orgId(),
  },
  handleSuccess: (response) => {
    if (handleSuccess) {
      handleSuccess(response);
    }
    // The API returns an array of sync status objects
    // Just show a simple success message
    return __('Repository synchronization started');
  },
  handleError,
  successToast: () => __('Repository synchronization started'),
  errorToast: (error) => {
    const message = getResponseErrorMsgs(error?.response);
    return message || __('Failed to start repository synchronization');
  },
});

export const cancelSync = (repositoryId, handleSuccess) => APIActions.delete({
  type: API_OPERATIONS.DELETE,
  key: CANCEL_SYNC_KEY,
  url: api.getApiUrl(`/sync_status/${repositoryId}`),
  handleSuccess,
  successToast: () => __('Sync canceled'),
  errorToast: error => syncStatusErrorToast(error),
});

export default getSyncStatus;
