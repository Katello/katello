// webpack/scenes/FlatpakRemoteInfo/FlatpakRemoteActions.js
import { API_OPERATIONS, APIActions, get } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import api from '../../services/api';
import FLATPAK_REMOTE_KEY, {
  GET_FLATPAK_REMOTE_INFO_KEY,
  GET_FLATPAK_REMOTE_STATUS_KEY,
  GET_FLATPAK_REMOTE_ERROR_KEY,
  getFlatpakRemoteDetailsKey,
} from './FlatpakRemoteConstants';

const flatpakSuccessToast = (response) => __('Flatpak remote info retrieved');

export const getFlatpakRemoteInfo = (id) => get({
  type: API_OPERATIONS.GET,
  key: getFlatpakRemoteDetailsKey(id),
  url: api.getApiUrl(`/flatpak_remote/${id}`),
  errorToast: (error) => __('Error retrieving Flatpak remote info: ') + error.response.data,
});