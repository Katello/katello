import {
  selectAPIStatus,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { AVAILABLE_HOST_COLLECTIONS_KEY, REMOVABLE_HOST_COLLECTIONS_KEY } from './HostCollectionsConstants';

export const selectAvailableHostCollections = state =>
  selectAPIResponse(state, AVAILABLE_HOST_COLLECTIONS_KEY) ?? {};

export const selectRemovableHostCollections = state =>
  selectAPIResponse(state, REMOVABLE_HOST_COLLECTIONS_KEY) ?? {};

export const selectAvailableHostCollectionsStatus = state =>
  selectAPIStatus(state, AVAILABLE_HOST_COLLECTIONS_KEY) || STATUS.PENDING;

export const selectRemovableHostCollectionsStatus = state =>
  selectAPIStatus(state, REMOVABLE_HOST_COLLECTIONS_KEY);
