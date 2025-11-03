import { API_OPERATIONS, put } from 'foremanReact/redux/API';
import { errorToast } from '../../../../../scenes/Tasks/helpers';
import { foremanApi } from '../../../../../services/api';

export const BULK_ADD_HOST_COLLECTIONS_KEY = 'BULK_ADD_HOST_COLLECTIONS';
export const BULK_REMOVE_HOST_COLLECTIONS_KEY = 'BULK_REMOVE_HOST_COLLECTIONS';

export const bulkAddHostCollections =
  (params, handleSuccess, handleError) => put({
    type: API_OPERATIONS.PUT,
    key: BULK_ADD_HOST_COLLECTIONS_KEY,
    url: foremanApi.getApiUrl('/hosts/bulk/add_host_collections'),
    handleSuccess,
    handleError,
    errorToast,
    params,
  });

export const bulkRemoveHostCollections =
  (params, handleSuccess, handleError) => put({
    type: API_OPERATIONS.PUT,
    key: BULK_REMOVE_HOST_COLLECTIONS_KEY,
    url: foremanApi.getApiUrl('/hosts/bulk/remove_host_collections'),
    handleSuccess,
    handleError,
    errorToast,
    params,
  });
