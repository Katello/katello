import { STATUS } from 'foremanReact/constants';
import {
  selectAPIResponse,
  selectAPIStatus,
  selectAPIError,
} from 'foremanReact/redux/API/APISelectors';
import { dockerTagDetailsKey } from './ManifestDetailsActions';

export const selectDockerTagDetails = (state, id) =>
  selectAPIResponse(state, dockerTagDetailsKey(id)) || {};

export const selectDockerTagDetailStatus =
  (state, id) => selectAPIStatus(state, dockerTagDetailsKey(id)) || STATUS.PENDING;

export const selectDockerTagDetailError =
  (state, id) => selectAPIError(state, dockerTagDetailsKey(id));
