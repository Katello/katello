import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { cvDetailsKey, cvDetailsRepoKey, REPOSITORY_TYPES } from '../ContentViewsConstants';

export const selectCVDetails = (state, cvId) =>
  selectAPIResponse(state, cvDetailsKey(cvId)) || {};

export const selectCVDetailStatus =
  (state, cvId) => selectAPIStatus(state, cvDetailsKey(cvId)) || STATUS.PENDING;

export const selectCVDetailError =
  (state, cvId) => selectAPIError(state, cvDetailsKey(cvId));

export const selectCVRepos = (state, cvId) =>
  selectAPIResponse(state, cvDetailsRepoKey(cvId)) || {};

export const selectCVReposStatus = (state, cvId) =>
  selectAPIStatus(state, cvDetailsRepoKey(cvId)) || STATUS.PENDING;

export const selectCVReposError = (state, cvId) =>
  selectAPIError(state, cvDetailsRepoKey(cvId));

export const selectRepoTypes = state =>
  selectAPIResponse(state, REPOSITORY_TYPES) || {};

export const selectRepoTypesStatus = state =>
  selectAPIStatus(state, REPOSITORY_TYPES) || STATUS.PENDING;

export const selectIsCVUpdating = state => state.katello?.contentViewDetails?.updating;
