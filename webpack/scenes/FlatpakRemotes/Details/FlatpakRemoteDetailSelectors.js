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

export const selectRemoteRepository = (state, repoId) =>
  selectAPIResponse(state, `FLATPAK_REMOTE_REPOSITORY_${repoId}`) || {};

export const selectRemoteRepositoryStatus = (state, repoId) =>
  selectAPIStatus(state, `FLATPAK_REMOTE_REPOSITORY_${repoId}`) || STATUS.PENDING;
