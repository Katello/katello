import { API_OPERATIONS, APIActions, get, put, post } from 'foremanReact/redux/API';
import { addToast } from 'foremanReact/redux/actions/toasts';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  RPM_MATCHING_CONTENT,
  UPDATE_CONTENT_VIEW,
  UPDATE_CONTENT_VIEW_FAILURE,
  UPDATE_CONTENT_VIEW_SUCCESS,
  CREATE_CONTENT_VIEW_FILTER_KEY,
  DELETE_CONTENT_VIEW_FILTER_KEY,
  DELETE_CONTENT_VIEW_FILTERS_KEY,
  EDIT_CONTENT_VIEW_FILTER,
  ADD_CONTENT_VIEW_FILTER_RULE,
  EDIT_CONTENT_VIEW_FILTER_RULE,
  REMOVE_CONTENT_VIEW_FILTER_RULE,
  DELETE_CONTENT_VIEW_FILTER_RULES_KEY,
  ADD_CONTENT_VIEW_FILTER_RULES_KEY,
  NOT_ADDED,
  ALL_STATUSES,
  REPOSITORY_TYPES,
  cvDetailsKey,
  cvDetailsRepoKey,
  cvDetailsFiltersKey,
  cvFilterDetailsKey,
  cvFilterPackageGroupsKey,
  cvFilterModuleStreamKey,
  cvDetailsHistoryKey,
  cvFilterRulesKey,
  cvDetailsComponentKey,
  cvDetailsVersionKey,
  cvAddComponentKey,
  cvRemoveComponentKey,
  addComponentSuccessMessage,
  removeComponentSuccessMessage,
  cvVersionPromoteKey,
  cvFilterRepoKey,
  cvVersionDetailsKey,
} from '../ContentViewsConstants';
import api from '../../../services/api';
import { getResponseErrorMsgs, apiError } from '../../../utils/helpers';
import { renderTaskStartedToast } from '../../Tasks/helpers';
import { cvErrorToast } from '../ContentViewsActions';

const getContentViewDetails = cvId => get({
  type: API_OPERATIONS.GET,
  key: cvDetailsKey(cvId),
  url: api.getApiUrl(`/content_views/${cvId}`),
});

const cvUpdateSuccess = (response, dispatch) => {
  const { data: { id } } = response;
  // Update CV info in redux with the updated CV info from API
  dispatch(getContentViewDetails(id));
  return dispatch(addToast({
    type: 'success',
    message: __(' Content view updated'),
  }));
};

export const getRPMMatchingContent = params => get({
  type: API_OPERATIONS.GET,
  key: RPM_MATCHING_CONTENT,
  url: api.getApiUrl('/packages'),
  params,
  errorToast: error => __(`Something went wrong while fetching matching content! ${getResponseErrorMsgs(error.response)}`),
});


export const updateContentView = (cvId, params) => dispatch => dispatch(put({
  type: API_OPERATIONS.PUT,
  key: cvDetailsKey(cvId),
  url: api.getApiUrl(`/content_views/${cvId}`),
  params,
  handleSuccess: response => cvUpdateSuccess(response, dispatch),
  handleError: error => dispatch(apiError(null, error)),
  actionTypes: {
    REQUEST: UPDATE_CONTENT_VIEW,
    SUCCESS: UPDATE_CONTENT_VIEW_SUCCESS,
    FAILURE: UPDATE_CONTENT_VIEW_FAILURE,
  },
}));

export const addComponent = params => put({
  type: API_OPERATIONS.PUT,
  key: cvAddComponentKey(params.compositeContentViewId),
  url: api.getApiUrl(`/content_views/${params.compositeContentViewId}/content_view_components/${params.components.id ? params.components.id : 'add'}`),
  params: params.components.id ? params.components : params,
  successToast: () => addComponentSuccessMessage(params.components.id),
  errorToast: error => __(`Something went wrong while adding component! ${getResponseErrorMsgs(error.response)}`),
});

export const removeComponent = params => put({
  type: API_OPERATIONS.PUT,
  key: cvRemoveComponentKey(params.compositeContentViewId),
  url: api.getApiUrl(`/content_views/${params.compositeContentViewId}/content_view_components/remove`),
  params,
  successToast: () => removeComponentSuccessMessage(params.component_ids.length),
  errorToast: error => __(`Something went wrong while removing component! ${getResponseErrorMsgs(error.response)}`),
});

export const createContentViewFilter = (cvId, params) => post({
  type: API_OPERATIONS.POST,
  key: CREATE_CONTENT_VIEW_FILTER_KEY,
  url: api.getApiUrl(`/content_view_filters?content_view_id=${cvId}`),
  params,
  successToast: () => __('Filter created'),
  errorToast: error => __(`Something went wrong while creating the filter! ${getResponseErrorMsgs(error.response)}`),
});

export const getContentViewRepositories = (cvId, params, status) => {
  const apiParams = { ...params };
  let apiUrl = `/content_views/${cvId}/repositories`;

  if (status === ALL_STATUSES) {
    apiUrl += '/show_all';
  } else if (status === NOT_ADDED) {
    apiParams.available_for = 'content_view';
  }

  return get({
    type: API_OPERATIONS.GET,
    key: cvDetailsRepoKey(cvId),
    url: api.getApiUrl(apiUrl),
    params: apiParams,
  });
};

export const getFilterRepositories = (cvId, filterId, params) => {
  const apiParams = { ...params };
  const apiUrl = `/content_views/${cvId}/repositories`;

  return get({
    type: API_OPERATIONS.GET,
    key: cvFilterRepoKey(filterId),
    url: api.getApiUrl(apiUrl),
    params: apiParams,
  });
};

export const editCVFilter = (filterId, params, handleSuccess) => put({
  type: API_OPERATIONS.PUT,
  key: EDIT_CONTENT_VIEW_FILTER,
  url: api.getApiUrl(`/content_view_filters/${filterId}`),
  params,
  handleSuccess,
  successToast: () => __('Filter edited successfully'),
  errorToast: error => __(`Something went wrong while editing the filter! ${getResponseErrorMsgs(error.response)}`),
});


export const getRepositoryTypes = () => get({
  type: API_OPERATIONS.GET,
  key: REPOSITORY_TYPES,
  errorToast: error => __(`Something went wrong while retrieving the repository types! ${getResponseErrorMsgs(error.response)}`),
  url: api.getApiUrl('/repositories/repository_types'),
});

export const getContentViewFilters = (cvId, params) => get({
  key: cvDetailsFiltersKey(cvId),
  params: { content_view_id: cvId, ...params },
  errorToast: error => __(`Something went wrong while retrieving the content view filters! ${getResponseErrorMsgs(error.response)}`),
  url: api.getApiUrl('/content_view_filters'),
});

export const deleteContentViewFilters = (cvId, ids, handleSuccess) => put({
  type: API_OPERATIONS.PUT,
  key: DELETE_CONTENT_VIEW_FILTERS_KEY,
  url: api.getApiUrl(`/content_views/${cvId}/remove_filters`),
  params: { filter_ids: ids },
  handleSuccess,
  successToast: () => __('Filters successfully deleted'),
  errorToast: error => __(`Something went wrong while deleting filters! ${getResponseErrorMsgs(error.response)}`),
});

export const deleteContentViewFilterRules = (filterId, ids, handleSuccess) => put({
  type: API_OPERATIONS.PUT,
  key: DELETE_CONTENT_VIEW_FILTER_RULES_KEY,
  url: api.getApiUrl(`/content_view_filters/${filterId}/remove_filter_rules`),
  params: { rule_ids: ids },
  handleSuccess,
  successToast: () => __('Filter rules successfully deleted'),
  errorToast: error => __(`Something went wrong while deleting filter rules! ${getResponseErrorMsgs(error.response)}`),
});

export const addContentViewFilterRules = (filterId, rulesParams, handleSuccess) => put({
  type: API_OPERATIONS.PUT,
  key: ADD_CONTENT_VIEW_FILTER_RULES_KEY,
  url: api.getApiUrl(`/content_view_filters/${filterId}/add_filter_rules`),
  params: { rules_params: rulesParams },
  handleSuccess,
  successToast: () => __('Filter rules successfully added'),
  errorToast: error => __(`Something went wrong while adding filter rules! ${getResponseErrorMsgs(error.response)}`),
});

export const deleteContentViewFilter = (filterId, handleSuccess) => APIActions.delete({
  type: API_OPERATIONS.DELETE,
  key: DELETE_CONTENT_VIEW_FILTER_KEY,
  url: api.getApiUrl(`/content_view_filters/${filterId}`),
  handleSuccess,
  successToast: () => __('Filter successfully deleted'),
  errorToast: error => __(`Something went wrong while deleting this filter! ${getResponseErrorMsgs(error.response)}`),
});

export const getCVFilterDetails = (cvId, filterId, params) => get({
  key: cvFilterDetailsKey(cvId, filterId),
  params: { contentViewId: cvId, ...params },
  errorToast: error => __(`Something went wrong while retrieving the content view filter! ${getResponseErrorMsgs(error.response)}`),
  url: api.getApiUrl(`/content_view_filters/${filterId}`),
});

export const getCVFilterPackageGroups = (cvId, filterId, params) => get({
  key: cvFilterPackageGroupsKey(cvId, filterId),
  params: {
    filter_id: filterId, show_all_for: 'content_view_filter', include_filter_ids: true, ...params,
  },
  errorToast: error => __(`Something went wrong while retrieving the content view filter! ${getResponseErrorMsgs(error.response)}`),
  url: api.getApiUrl('/package_groups'),
});

export const getCVFilterModuleStreams = (cvId, filterId, params) => get({
  key: cvFilterModuleStreamKey(cvId, filterId),
  params: {
    filter_id: filterId, show_all_for: 'content_view_filter', include_filter_ids: true, ...params,
  },
  errorToast: error => __(`Something went wrong while retrieving the content view filter! ${getResponseErrorMsgs(error.response)}`),
  url: api.getApiUrl('/module_streams'),
});

export const editCVFilterRule = (filterId, params, handleSuccess) => put({
  type: API_OPERATIONS.PUT,
  key: EDIT_CONTENT_VIEW_FILTER_RULE,
  url: api.getApiUrl(`/content_view_filters/${filterId}/rules/${params.id}`),
  params,
  handleSuccess,
  successToast: () => __('Filter rule edited successfully'),
  errorToast: error => __(`Something went wrong while editing a filter rule! ${getResponseErrorMsgs(error.response)}`),
});

export const addCVFilterRule = (filterId, params, handleSuccess) => post({
  type: API_OPERATIONS.POST,
  key: ADD_CONTENT_VIEW_FILTER_RULE,
  url: api.getApiUrl(`/content_view_filters/${filterId}/rules`),
  params,
  handleSuccess,
  successToast: () => __('Filter rule added successfully'),
  errorToast: error => __(`Something went wrong while adding a filter rule! ${getResponseErrorMsgs(error.response)}`),
});

export const removeCVFilterRule = (filterId, packageGroupFilterId, handleSuccess) =>
  APIActions.delete({
    type: API_OPERATIONS.DELETE,
    key: REMOVE_CONTENT_VIEW_FILTER_RULE,
    url: api.getApiUrl(`/content_view_filters/${filterId}/rules/${packageGroupFilterId}`),
    handleSuccess,
    successToast: () => __('Filter rule removed successfully'),
    errorToast: error => __(`Something went wrong while removing a filter rule! ${getResponseErrorMsgs(error.response)}`),
  });

export const getContentViewHistories = (cvId, params) => {
  const apiParams = { ...params };
  const apiUrl = `/content_views/${cvId}/history`;
  return get({
    key: cvDetailsHistoryKey(cvId),
    params: apiParams,
    errorToast: error => __(`Something went wrong while retrieving the content view history! ${getResponseErrorMsgs(error.response)}`),
    url: api.getApiUrl(apiUrl),
  });
};

export const getCVFilterRules = (filterId, params) => get({
  key: cvFilterRulesKey(filterId),
  params: { ...params },
  errorToast: error => __(`Something went wrong while retrieving the content view filter rules! ${getResponseErrorMsgs(error.response)}`),
  url: api.getApiUrl(`/content_view_filters/${filterId}/rules`),
});

export const getContentViewComponents = (cvId, params, statusSelected) => {
  const apiParams = { ...params, status: statusSelected };
  const apiUrl = `/content_views/${cvId}/content_view_components/show_all`;
  return get({
    key: cvDetailsComponentKey(cvId),
    params: apiParams,
    errorToast: error => __(`Something went wrong while retrieving the content view components! ${getResponseErrorMsgs(error.response)}`),
    url: api.getApiUrl(apiUrl),
  });
};

export const getContentViewVersions = (cvId, params) => {
  const apiParams = { content_view_id: cvId, ...params };
  const apiUrl = '/content_view_versions/';
  return get({
    key: cvDetailsVersionKey(cvId),
    params: apiParams,
    errorToast: error => __(`Something went wrong while retrieving the content view versions! ${getResponseErrorMsgs(error.response)}`),
    url: api.getApiUrl(apiUrl),
  });
};

export const getContentViewVersionDetails = (versionId, cvId, handleSuccess) =>
  APIActions.get({
    type: API_OPERATIONS.GET,
    key: cvVersionDetailsKey(versionId, cvId),
    url: api.getApiUrl(`/content_view_versions/${versionId}`),
    handleSuccess,
    errorToast: error => __(`Something went wrong while getting version details. ${getResponseErrorMsgs(error.response)}`),
  });

export const editContentViewVersionDetails = (versionId, cvId, params, handleSuccess) =>
  APIActions.put({
    type: API_OPERATIONS.PUT,
    key: cvVersionDetailsKey(versionId, cvId),
    url: api.getApiUrl(`/content_view_versions/${versionId}`),
    params,
    handleSuccess,
    errorToast: error => __(`Something went wrong while editing version details. ${getResponseErrorMsgs(error.response)}`),
  });

export const promoteContentViewVersion = params => post({
  type: API_OPERATIONS.POST,
  key: cvVersionPromoteKey(params.id, params.versionEnvironments),
  url: api.getApiUrl(`/content_view_versions/${params.id}/promote`),
  params,
  handleSuccess: response => renderTaskStartedToast(response.data),
  errorToast: error => cvErrorToast(error),
});

export default getContentViewDetails;
