import { API_OPERATIONS, get, put } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import { flatpakRemoteDetailsKey,
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

export default getFlatpakRemoteDetails;
