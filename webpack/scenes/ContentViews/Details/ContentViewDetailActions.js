import { API_OPERATIONS, APIActions, get, put, post } from 'foremanReact/redux/API';
import { addToast } from 'foremanReact/redux/actions/toasts';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  UPDATE_CONTENT_VIEW,
  UPDATE_CONTENT_VIEW_FAILURE,
  UPDATE_CONTENT_VIEW_SUCCESS,
  CREATE_CONTENT_VIEW_FILTER_KEY,
  DELETE_CONTENT_VIEW_FILTER_KEY,
  DELETE_CONTENT_VIEW_FILTERS_KEY,
  NOT_ADDED,
  ALL_STATUSES,
  REPOSITORY_TYPES,
  cvDetailsKey,
  cvDetailsRepoKey,
  cvDetailsFiltersKey,
  cvFilterDetailsKey,
  cvFilterPackageGroupsKey,
  cvDetailsHistoryKey,
  cvFilterRulesKey,
  cvDetailsComponentKey,
  cvDetailsVersionKey,
  cvAddComponentKey,
  cvRemoveComponentKey,
  addComponentSuccessMessage,
  removeComponentSuccessMessage,
} from '../ContentViewsConstants';
import api from '../../../services/api';
import { getResponseErrorMsgs, apiError } from '../../../utils/helpers';

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

export default getContentViewDetails;
