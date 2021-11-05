import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { REPOSITORY_SETS_KEY } from './RepositorySetsConstants';

export const selectRepositorySets = state =>
  selectAPIResponse(state, REPOSITORY_SETS_KEY) || {};

export const selectRepositorySetsStatus = state =>
  selectAPIStatus(state, REPOSITORY_SETS_KEY) || STATUS.PENDING;

export const selectRepositorySetsError = state =>
  selectAPIError(state, REPOSITORY_SETS_KEY);
