import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { ENVIRONMENT_PATHS_KEY } from './EnvironmentPathConstants';

export const selectEnvironmentPaths = state =>
  selectAPIResponse(state, ENVIRONMENT_PATHS_KEY) || {};

export const selectEnvironmentPathsStatus = state =>
  selectAPIStatus(state, ENVIRONMENT_PATHS_KEY) || STATUS.PENDING;

export const selectEnvironmentPathsError = state =>
  selectAPIError(state, ENVIRONMENT_PATHS_KEY);
