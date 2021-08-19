import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import {
  cvDetailsKey,
  cvDetailsRepoKey,
  cvDetailsFiltersKey,
  cvFilterDetailsKey,
  cvFilterPackageGroupsKey,
  cvDetailsHistoryKey,
  cvFilterRulesKey,
  cvDetailsVersionKey,
  REPOSITORY_TYPES,
  cvDetailsComponentKey,
  cvAddComponentKey,
  cvRemoveComponentKey,
  CREATE_CONTENT_VIEW_FILTER_KEY,
  RPM_MATCHING_CONTENT,
} from '../ContentViewsConstants';
import { pollTaskKey } from '../../Tasks/helpers';

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

export const selectCVFilters = (state, cvId) =>
  selectAPIResponse(state, cvDetailsFiltersKey(cvId)) || {};

export const selectCVFiltersStatus = (state, cvId) =>
  selectAPIStatus(state, cvDetailsFiltersKey(cvId)) || STATUS.PENDING;

export const selectCVFiltersError = (state, cvId) =>
  selectAPIError(state, cvDetailsFiltersKey(cvId));

export const selectCVFilterDetails = (state, cvId, filterId) =>
  selectAPIResponse(state, cvFilterDetailsKey(cvId, filterId)) || {};

export const selectCVFilterDetailStatus = (state, cvId, filterId) =>
  selectAPIStatus(state, cvFilterDetailsKey(cvId, filterId)) || STATUS.PENDING;

export const selectCVFilterDetailError = (state, cvId, filterId) =>
  selectAPIError(state, cvFilterDetailsKey(cvId, filterId));

export const selectCVFilterPackageGroups = (state, cvId, filterId) =>
  selectAPIResponse(state, cvFilterPackageGroupsKey(cvId, filterId));

export const selectCVFilterPackageGroupStatus = (state, cvId, filterId) =>
  selectAPIStatus(state, cvFilterPackageGroupsKey(cvId, filterId)) || STATUS.PENDING;

export const selectCVFilterPackageGroupError = (state, cvId, filterId) =>
  selectAPIError(state, cvFilterPackageGroupsKey(cvId, filterId));

export const selectCVHistories = (state, cvId) =>
  selectAPIResponse(state, cvDetailsHistoryKey(cvId)) || {};

export const selectCVHistoriesStatus = (state, cvId) =>
  selectAPIStatus(state, cvDetailsHistoryKey(cvId)) || STATUS.PENDING;

export const selectCVHistoriesError = (state, cvId) =>
  selectAPIError(state, cvDetailsHistoryKey(cvId));

export const selectCVFilterRules = (state, filterId) =>
  selectAPIResponse(state, cvFilterRulesKey(filterId));

export const selectCVFilterRulesStatus = (state, filterId) =>
  selectAPIStatus(state, cvFilterRulesKey(filterId)) || STATUS.PENDING;

export const selectRPMMatchContent = state =>
  selectAPIResponse(state, RPM_MATCHING_CONTENT);

export const selectRPMMatchContentStatus = state =>
  selectAPIStatus(state, RPM_MATCHING_CONTENT) || STATUS.PENDING;

export const selectCVComponents = (state, cvId) =>
  selectAPIResponse(state, cvDetailsComponentKey(cvId)) || {};

export const selectCVComponentsStatus = (state, cvId) =>
  selectAPIStatus(state, cvDetailsComponentKey(cvId)) || STATUS.PENDING;

export const selectCVComponentsError = (state, cvId) =>
  selectAPIError(state, cvDetailsComponentKey(cvId));

export const selectCVVersions = (state, cvId) =>
  selectAPIResponse(state, cvDetailsVersionKey(cvId)) || {};

export const selectCVVersionsStatus = (state, cvId) =>
  selectAPIStatus(state, cvDetailsVersionKey(cvId)) || STATUS.PENDING;

export const selectCVVersionsError = (state, cvId) =>
  selectAPIError(state, cvDetailsVersionKey(cvId));

export const selectPublishTaskPoll = (state, cvVersionPublishKey) =>
  selectAPIResponse(state, pollTaskKey(cvVersionPublishKey)) || {};

export const selectPublishTaskPollStatus = (state, cvVersionPublishKey) =>
  selectAPIStatus(state, pollTaskKey(cvVersionPublishKey)) || STATUS.PENDING;

export const selectTaskPoll = (state, key) =>
  selectAPIResponse(state, pollTaskKey(key)) || {};

export const selectTaskPollStatus = (state, key) =>
  selectAPIStatus(state, pollTaskKey(key)) || STATUS.PENDING;

export const selectCVComponentAdd = (state, cvId) =>
  selectAPIResponse(state, cvAddComponentKey(cvId));

export const selectCVComponentAddStatus = (state, cvId) =>
  selectAPIStatus(state, cvAddComponentKey(cvId)) || STATUS.PENDING;

export const selectCVComponentAddError = (state, cvId) =>
  selectAPIError(state, cvAddComponentKey(cvId));

export const selectCVComponentRemove = (state, cvId) =>
  selectAPIResponse(state, cvRemoveComponentKey(cvId));

export const selectCVComponentRemoveStatus = (state, cvId) =>
  selectAPIStatus(state, cvRemoveComponentKey(cvId)) || STATUS.PENDING;

export const selectCVComponentRemoveError = (state, cvId) =>
  selectAPIError(state, cvRemoveComponentKey(cvId));

export const selectCreateContentViewFilter = state =>
  selectAPIResponse(state, CREATE_CONTENT_VIEW_FILTER_KEY) || {};

export const selectCreateContentViewFilterStatus = state =>
  selectAPIStatus(state, CREATE_CONTENT_VIEW_FILTER_KEY) || STATUS.PENDING;

export const selectCreateContentViewFilterError = state =>
  selectAPIError(state, CREATE_CONTENT_VIEW_FILTER_KEY);

export const selectIsCVUpdating = state => state.katello?.contentViewDetails?.updating;
