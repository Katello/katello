import { API_OPERATIONS, APIActions, get, put, post } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import { lowerCase } from 'lodash';
import {
  RPM_PACKAGES_CONTENT,
  RPM_PACKAGE_GROUPS_CONTENT,
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
  ACTIVATION_KEY_KEY,
  HOSTS_KEY,
  cvDetailsKey,
  cvDetailsRepoKey,
  cvDetailsFiltersKey,
  cvFilterDetailsKey,
  cvFilterPackageGroupsKey,
  cvFilterModuleStreamKey,
  cvFilterErratumIDKey,
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
  cvRemoveVersionKey,
  REPOSITORY_CONTENT,
  FILE_CONTENT,
  ERRATA_CONTENT,
  MODULE_STREAMS_CONTENT,
  DEB_PACKAGES_CONTENT,
  DOCKER_TAGS_CONTENT,
  generatedContentKey,
  STATUS_TRANSLATIONS_ENUM,
  bulkRemoveVersionKey,
  cvRPMPackagesCompareKey,
  cvPackageGroupsCompareKey,
  cvErrataCompareKey,
  cvModuleStreamsCompareKey,
  cvDockerTagsCompareKey,
  cvDebPackagesCompareKey,
  filesCompareKey,
  genericContentCompareKey,
} from '../ContentViewsConstants';
import api, { foremanApi, orgId } from '../../../services/api';
import { getResponseErrorMsgs } from '../../../utils/helpers';
import { renderTaskStartedToast } from '../../Tasks/helpers';
import { cvErrorToast } from '../ContentViewsActions';

const getContentViewDetails = (cvId, extraParams = {}) => get({
  type: API_OPERATIONS.GET,
  key: cvDetailsKey(cvId),
  params: { organization_id: orgId(), include_permissions: true, ...extraParams },
  url: api.getApiUrl(`/content_views/${cvId}`),
});

export const getContent = (pluralLabel, params) => get({
  type: API_OPERATIONS.GET,
  key: generatedContentKey(pluralLabel),
  url: api.getApiUrl(`/${pluralLabel}`),
  params,
  errorToast: error => __(`Something went wrong while fetching ${lowerCase(pluralLabel)}! ${getResponseErrorMsgs(error.response)}`),
});

export const getRPMPackages = params => get({
  type: API_OPERATIONS.GET,
  key: RPM_PACKAGES_CONTENT,
  url: api.getApiUrl('/packages'),
  params,
  errorToast: error => __(`Something went wrong while fetching rpm packages! ${getResponseErrorMsgs(error.response)}`),
});

export const getRPMPackagesComparison = (versionOne, versionTwo, params) => {
  const versions = { content_view_version_ids: [versionOne, versionTwo] };
  const apiParams = { ...versions, ...params };
  const apiUrl = '/packages/compare';
  return get({
    key: cvRPMPackagesCompareKey(versionOne, versionTwo),
    params: apiParams,
    errorToast: error => __(`Something went wrong while retrieving the packages! ${getResponseErrorMsgs(error.response)}`),
    url: api.getApiUrl(apiUrl),
  });
};

export const getPackageGroupsComparison = (versionOne, versionTwo, params) => {
  const versions = { content_view_version_ids: [versionOne, versionTwo] };
  const apiParams = { ...versions, ...params };
  const apiUrl = '/package_groups/compare';
  return get({
    key: cvPackageGroupsCompareKey(versionOne, versionTwo),
    params: apiParams,
    errorToast: error => __(`Something went wrong while retrieving the package groups! ${getResponseErrorMsgs(error.response)}`),
    url: api.getApiUrl(apiUrl),
  });
};

export const getErrataComparison = (versionOne, versionTwo, params) => {
  const versions = { content_view_version_ids: [versionOne, versionTwo] };
  const apiParams = { ...versions, ...params };
  const apiUrl = '/errata/compare';
  return get({
    key: cvErrataCompareKey(versionOne, versionTwo),
    params: apiParams,
    errorToast: error => __(`Something went wrong while retrieving the errata! ${getResponseErrorMsgs(error.response)}`),
    url: api.getApiUrl(apiUrl),
  });
};

export const getModuleStreamsComparison = (versionOne, versionTwo, params) => {
  const versions = { content_view_version_ids: [versionOne, versionTwo] };
  const apiParams = { ...versions, ...params };
  const apiUrl = '/module_streams/compare';
  return get({
    key: cvModuleStreamsCompareKey(versionOne, versionTwo),
    params: apiParams,
    errorToast: error => __(`Something went wrong while retrieving the module streams! ${getResponseErrorMsgs(error.response)}`),
    url: api.getApiUrl(apiUrl),
  });
};

export const getDebPackagesComparison = (versionOne, versionTwo, params) => {
  const versions = { content_view_version_ids: [versionOne, versionTwo] };
  const apiParams = { ...versions, ...params };
  const apiUrl = '/debs/compare';
  return get({
    key: cvDebPackagesCompareKey(versionOne, versionTwo),
    params: apiParams,
    errorToast: error => __(`Something went wrong while retrieving the deb packages! ${getResponseErrorMsgs(error.response)}`),
    url: api.getApiUrl(apiUrl),
  });
};

export const getDockerTagsComparison = (versionOne, versionTwo, params) => {
  const versions = { content_view_version_ids: [versionOne, versionTwo] };
  const apiParams = { ...versions, ...params };
  const apiUrl = '/docker_tags/compare';
  return get({
    key: cvDockerTagsCompareKey(versionOne, versionTwo),
    params: apiParams,
    errorToast: error => __(`Something went wrong while retrieving the container tags! ${getResponseErrorMsgs(error.response)}`),
    url: api.getApiUrl(apiUrl),
  });
};

export const getFilesComparison = (versionOne, versionTwo, params) => {
  const versions = { content_view_version_ids: [versionOne, versionTwo] };
  const apiParams = { ...versions, ...params };
  const apiUrl = '/files/compare';
  return get({
    key: filesCompareKey(versionOne, versionTwo),
    params: apiParams,
    errorToast: error => __(`Something went wrong while retrieving the files! ${getResponseErrorMsgs(error.response)}`),
    url: api.getApiUrl(apiUrl),
  });
};

export const getContentComparison = (pluralLabel, versionOne, versionTwo, params) => {
  const versions = { content_view_version_ids: [versionOne, versionTwo] };
  const apiParams = { ...versions, ...params };
  const apiUrl = `/${pluralLabel}/compare`;
  return get({
    key: genericContentCompareKey(pluralLabel, versionOne, versionTwo),
    params: apiParams,
    errorToast: error => __(`Something went wrong while retrieving the content! ${getResponseErrorMsgs(error.response)}`),
    url: api.getApiUrl(apiUrl),
  });
};

export const getFiles = params => get({
  type: API_OPERATIONS.GET,
  key: FILE_CONTENT,
  url: api.getApiUrl('/files'),
  params,
  errorToast: error => __(`Something went wrong while fetching files! ${getResponseErrorMsgs(error.response)}`),
});

export const updateContentView = (cvId, params, handleSuccess) => put({
  type: API_OPERATIONS.PUT,
  key: cvDetailsKey(cvId),
  url: api.getApiUrl(`/content_views/${cvId}`),
  handleSuccess,
  params: { include_permissions: true, ...params },
  successToast: () => __(' Content view updated'),
  errorToast: error => getResponseErrorMsgs(error.response),
  updateData: (_prevState, respState) => respState,
  actionTypes: {
    REQUEST: UPDATE_CONTENT_VIEW,
    SUCCESS: UPDATE_CONTENT_VIEW_SUCCESS,
    FAILURE: UPDATE_CONTENT_VIEW_FAILURE,
  },
});

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

export const getDockerTags = params => get({
  type: API_OPERATIONS.GET,
  key: DOCKER_TAGS_CONTENT,
  url: api.getApiUrl('/docker_tags'),
  params,
  errorToast: error => __(`Something went wrong while getting container tags! ${getResponseErrorMsgs(error.response)}`),
});

export const getErrata = params => get({
  type: API_OPERATIONS.GET,
  key: ERRATA_CONTENT,
  url: api.getApiUrl('/errata'),
  params,
  errorToast: error => __(`Something went wrong while getting errata! ${getResponseErrorMsgs(error.response)}`),
});

export const getDebPackages = params => get({
  type: API_OPERATIONS.GET,
  key: DEB_PACKAGES_CONTENT,
  url: api.getApiUrl('/debs'),
  params,
  errorToast: error => __(`Something went wrong while getting deb packages! ${getResponseErrorMsgs(error.response)}`),
});

export const getModuleStreams = params => get({
  type: API_OPERATIONS.GET,
  key: MODULE_STREAMS_CONTENT,
  url: api.getApiUrl('/module_streams'),
  params,
  errorToast: error => __(`Something went wrong while getting module streams! ${getResponseErrorMsgs(error.response)}`),
});

export const getRepositories = params => get({
  type: API_OPERATIONS.GET,
  key: REPOSITORY_CONTENT,
  url: api.getApiUrl('/repositories'),
  params,
  errorToast: error => __(`Something went wrong while getting repositories! ${getResponseErrorMsgs(error.response)}`),
});

export const getContentViewRepositories = (cvId, params, status) => {
  const apiParams = { organization_id: orgId(), ...params };
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

export const editCVFilter = (filterId, params, handleSuccess, handleError) => put({
  type: API_OPERATIONS.PUT,
  key: EDIT_CONTENT_VIEW_FILTER,
  url: api.getApiUrl(`/content_view_filters/${filterId}`),
  params,
  handleSuccess,
  handleError,
  successToast: () => __('Filter edited'),
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

export const getActivationKeys = params => get({
  key: ACTIVATION_KEY_KEY,
  params: { organization_id: orgId(), ...params },
  errorToast: error => __(`Something went wrong while retrieving the activation keys! ${getResponseErrorMsgs(error.response)}`),
  url: api.getApiUrl('/activation_keys'),
});

export const getHosts = params => get({
  key: HOSTS_KEY,
  params: { organization_id: orgId(), ...params },
  errorToast: error => __(`Something went wrong while retrieving the hosts! ${getResponseErrorMsgs(error.response)}`),
  url: foremanApi.getApiUrl('/hosts'),
});

export const deleteContentViewFilters = (cvId, ids, handleSuccess) => put({
  type: API_OPERATIONS.PUT,
  key: DELETE_CONTENT_VIEW_FILTERS_KEY,
  url: api.getApiUrl(`/content_views/${cvId}/remove_filters`),
  params: { filter_ids: ids },
  handleSuccess,
  successToast: () => __('Filters deleted'),
  errorToast: error => __(`Something went wrong while deleting filters! ${getResponseErrorMsgs(error.response)}`),
});

export const deleteContentViewFilterRules = (filterId, ids, handleSuccess) => put({
  type: API_OPERATIONS.PUT,
  key: DELETE_CONTENT_VIEW_FILTER_RULES_KEY,
  url: api.getApiUrl(`/content_view_filters/${filterId}/remove_filter_rules`),
  params: { rule_ids: ids },
  handleSuccess,
  successToast: () => __('Filter rules deleted'),
  errorToast: error => __(`Something went wrong while deleting filter rules! ${getResponseErrorMsgs(error.response)}`),
});

export const addContentViewFilterRules = (filterId, rulesParams, handleSuccess) => put({
  type: API_OPERATIONS.PUT,
  key: ADD_CONTENT_VIEW_FILTER_RULES_KEY,
  url: api.getApiUrl(`/content_view_filters/${filterId}/add_filter_rules`),
  params: { rules_params: rulesParams },
  handleSuccess,
  successToast: () => __('Filter rules added'),
  errorToast: error => __(`Something went wrong while adding filter rules! ${getResponseErrorMsgs(error.response)}`),
});

export const deleteContentViewFilter = (filterId, handleSuccess) => APIActions.delete({
  type: API_OPERATIONS.DELETE,
  key: DELETE_CONTENT_VIEW_FILTER_KEY,
  url: api.getApiUrl(`/content_view_filters/${filterId}`),
  handleSuccess,
  successToast: () => __('Filter deleted'),
  errorToast: error => __(`Something went wrong while deleting this filter! ${getResponseErrorMsgs(error.response)}`),
});

export const getCVFilterDetails = (cvId, filterId, params) => get({
  key: cvFilterDetailsKey(cvId, filterId),
  params: { contentViewId: cvId, ...params },
  errorToast: error => __(`Something went wrong while retrieving the content view filter! ${getResponseErrorMsgs(error.response)}`),
  url: api.getApiUrl(`/content_view_filters/${filterId}`),
});

export const getPackageGroups = params => get({
  key: RPM_PACKAGE_GROUPS_CONTENT,
  url: api.getApiUrl('/package_groups'),
  params,
  errorToast: error => __(`Something went wrong while retrieving package groups! ${getResponseErrorMsgs(error.response)}`),
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

export const getCVFilterErrata = (cvId, filterId, params = {}, statusSelected = ALL_STATUSES) => {
  let apiParams = { filter_id: filterId, include_filter_ids: true, ...params };
  if (statusSelected === ALL_STATUSES) {
    apiParams = { show_all_for: 'content_view_filter', ...apiParams };
  } else if (statusSelected === NOT_ADDED) {
    apiParams = { available_for: 'content_view_filter', ...apiParams };
  }

  return get({
    key: cvFilterErratumIDKey(cvId, filterId),
    params: apiParams,
    errorToast: error => __(`Something went wrong while retrieving the content view filter! ${getResponseErrorMsgs(error.response)}`),
    url: api.getApiUrl('/errata'),
  });
};

export const editCVFilterRule = (filterId, params, handleSuccess) => put({
  type: API_OPERATIONS.PUT,
  key: EDIT_CONTENT_VIEW_FILTER_RULE,
  url: api.getApiUrl(`/content_view_filters/${filterId}/rules/${params.id}`),
  params,
  handleSuccess,
  successToast: () => __('Filter rule edited'),
  errorToast: error => __(`Something went wrong while editing a filter rule! ${getResponseErrorMsgs(error.response)}`),
});

export const addCVFilterRule = (filterId, params, handleSuccess) => post({
  type: API_OPERATIONS.POST,
  key: ADD_CONTENT_VIEW_FILTER_RULE,
  url: api.getApiUrl(`/content_view_filters/${filterId}/rules`),
  params,
  handleSuccess,
  successToast: () => __('Filter rule added'),
  errorToast: error => __(`Something went wrong while adding a filter rule! ${getResponseErrorMsgs(error.response)}`),
});

export const removeCVFilterRule = (filterId, packageGroupFilterId, handleSuccess) =>
  APIActions.delete({
    type: API_OPERATIONS.DELETE,
    key: REMOVE_CONTENT_VIEW_FILTER_RULE,
    url: api.getApiUrl(`/content_view_filters/${filterId}/rules/${packageGroupFilterId}`),
    handleSuccess,
    successToast: () => __('Filter rule removed'),
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
  const apiParams = { ...params, status: STATUS_TRANSLATIONS_ENUM[statusSelected] };
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
  const apiUrl = '/content_view_versions';
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
    successToast: () => __('Version details updated.'),
    errorToast: error => __(`Something went wrong while editing version details. ${getResponseErrorMsgs(error.response)}`),
  });

export const bulkDeleteContentViewVersion = (cvId, params, handleSuccess, handleError) => put({
  type: API_OPERATIONS.PUT,
  key: bulkRemoveVersionKey(cvId),
  url: api.getApiUrl(`/content_views/${cvId}/bulk_delete_versions`),
  params,
  handleSuccess: (response) => {
    renderTaskStartedToast(response?.data);
    handleSuccess(response);
  },
  handleError,
  errorToast: error => __(`Something went wrong while deleting versions ${getResponseErrorMsgs(error.response)}`),
});

export const removeContentViewVersion =
  (cvId, versionId, versionEnvironments, params, handleSuccess, handleError) =>
    put({
      type: API_OPERATIONS.PUT,
      key: cvRemoveVersionKey(versionId, versionEnvironments),
      url: api.getApiUrl(`/content_views/${cvId}/remove`),
      params,
      handleSuccess: (response) => {
        renderTaskStartedToast(response.data);
        if (handleSuccess) return handleSuccess(response);
        return undefined; // consistent-return
      },
      handleError,
      errorToast: error => cvErrorToast(error),
    });


export const promoteContentViewVersion = (params, handleSuccess) => post({
  type: API_OPERATIONS.POST,
  key: cvVersionPromoteKey(params.id, params.versionEnvironments),
  url: api.getApiUrl(`/content_view_versions/${params.id}/promote`),
  params,
  handleSuccess: (response) => {
    if (handleSuccess) return handleSuccess();
    return renderTaskStartedToast(response.data);
  },
  errorToast: error => cvErrorToast(error),
});

export default getContentViewDetails;
