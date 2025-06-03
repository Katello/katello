import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import FLATPAK_REMOTES_KEY from './FlatpakRemotesConstants';

export const selectFlatpakRemotes = (state, index = '') => selectAPIResponse(state, FLATPAK_REMOTES_KEY + index) || {};

export const selectFlatpakRemotesStatus = (state, index = '') =>
  selectAPIStatus(state, FLATPAK_REMOTES_KEY + index) || STATUS.PENDING;

export const selectFlatpakRemotesError = (state, index = '') =>
  selectAPIError(state, FLATPAK_REMOTES_KEY + index);
