import { API_OPERATIONS, get, post, put } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import { flatpakRemoteDetailsKey,
  flatpakRemoteRepositoriesKey,
  UPDATE_FLATPAK_REMOTE,
  UPDATE_FLATPAK_REMOTE_SUCCESS,
  UPDATE_FLATPAK_REMOTE_FAILURE } from '../FlatpakRemotesConstants';
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

export const updateFlatpakRemote = (frId, params, handleSuccess) => put({
  type: API_OPERATIONS.PUT,
  key: flatpakRemoteDetailsKey(frId),
  url: api.getApiUrl(`/flatpak_remotes/${frId}`),
  handleSuccess,
  params: { include_permissions: true, ...params },
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

export default getFlatpakRemoteDetails;
