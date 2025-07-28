import { API_OPERATIONS, APIActions, get, post, put } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import { flatpakRemoteDetailsKey,
  flatpakRemoteRepositoriesKey,
  UPDATE_FLATPAK_REMOTE,
  UPDATE_FLATPAK_REMOTE_SUCCESS,
  UPDATE_FLATPAK_REMOTE_FAILURE,
  DELETE_FLATPAK_REMOTE_KEY,
  SCAN_FLATPAK_REMOTE_KEY } from '../FlatpakRemotesConstants';
import api, { orgId } from '../../../services/api';
import { getResponseErrorMsgs } from '../../../utils/helpers';

const getFlatpakRemoteDetails = (id, extraParams = {}) => get({
  type: API_OPERATIONS.GET,
  key: flatpakRemoteDetailsKey(id),
  params: { organization_id: orgId(), include_permissions: true, ...extraParams },
  url: api.getApiUrl(`/flatpak_remotes/${id}`),
});

export const getRemoteRepositories = frId => () =>
  get({
    type: API_OPERATIONS.GET,
    key: flatpakRemoteRepositoriesKey(frId),
    url: api.getApiUrl(`/flatpak_remotes/${frId}/flatpak_remote_repositories`),
    params: { organization_id: orgId() },
  });

export const updateFlatpakRemote = (frId, params, handleSuccess, handleError) => put({
  type: API_OPERATIONS.PUT,
  key: flatpakRemoteDetailsKey(frId),
  url: api.getApiUrl(`/flatpak_remotes/${frId}`),
  handleSuccess,
  handleError,
  params,
  successToast: () => __('Flatpak remote updated'),
  errorToast: error => getResponseErrorMsgs(error.response),
  updateData: (_prevState, respState) => respState,
  actionTypes: {
    REQUEST: UPDATE_FLATPAK_REMOTE,
    SUCCESS: UPDATE_FLATPAK_REMOTE_SUCCESS,
    FAILURE: UPDATE_FLATPAK_REMOTE_FAILURE,
  },
});

export const mirrorFlatpakRepository = (
  flatpakRepoId,
  productName,
  handleSuccess,
  handleError,
) =>
  post({
    type: API_OPERATIONS.POST,
    key: flatpakRemoteRepositoriesKey(flatpakRepoId),
    url: api.getApiUrl(`/flatpak_remote_repositories/${flatpakRepoId}/mirror`),
    params: { product_name: productName, organization_id: orgId() },
    handleSuccess,
    handleError,
    successToast: () => __('Repository mirroring task started in the background'),
    errorToast: error => getResponseErrorMsgs(error.response),
  });

export const deleteFlatpakRemote = (id, handleSuccess) => APIActions.delete({
  type: API_OPERATIONS.DELETE,
  key: DELETE_FLATPAK_REMOTE_KEY,
  url: api.getApiUrl(`/flatpak_remotes/${id}`),
  handleSuccess,
  successToast: () => __('Flatpak remote deleted'),
  errorToast: error => __('Flatpak remote could not be deleted: ') + getResponseErrorMsgs(error.response),
});

export const scanFlatpakRemote = (id, handleSuccess, handleError) => post({
  type: API_OPERATIONS.POST,
  key: SCAN_FLATPAK_REMOTE_KEY,
  url: api.getApiUrl(`/flatpak_remotes/${id}/scan`),
  handleSuccess,
  handleError,
  successToast: () => __('Flatpak remote scanning task started in the background'),
  errorToast: error => __('Flatpak remote scan could not be started: ') +
        getResponseErrorMsgs(error.response),
});

export default getFlatpakRemoteDetails;
