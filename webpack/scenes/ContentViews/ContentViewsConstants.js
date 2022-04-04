import { translate as __ } from 'foremanReact/common/I18n';
import { toUpper } from 'lodash';

const CONTENT_VIEWS_KEY = 'CONTENT_VIEWS';
export const CREATE_CONTENT_VIEW_KEY = 'CONTENT_VIEW_CREATE';
export const COPY_CONTENT_VIEW_KEY = 'CONTENT_VIEW_COPY';
export const CREATE_CONTENT_VIEW_FILTER_KEY = 'CONTENT_VIEW_FILTER_CREATE';
export const DELETE_CONTENT_VIEW_FILTER_KEY = 'CONTENT_VIEW_FILTER_DELETE';
export const DELETE_CONTENT_VIEW_FILTERS_KEY = 'CONTENT_VIEW_FILTERS_DELETE';
export const DELETE_CONTENT_VIEW_FILTER_RULES_KEY = 'CONTENT_VIEW_FILTER_RULES_DELETE';
export const ADD_CONTENT_VIEW_FILTER_RULES_KEY = 'CONTENT_VIEW_FILTER_RULES_ADD';
export const PUBLISH_CONTENT_VIEW_KEY = 'CONTENT_VIEW_PUBLISH';
export const UPDATE_CONTENT_VIEW = 'UPDATE_CONTENT_VIEW';
export const UPDATE_CONTENT_VIEW_SUCCESS = 'UPDATE_CONTENT_VIEW_SUCCESS';
export const UPDATE_CONTENT_VIEW_FAILURE = 'UPDATE_CONTENT_VIEW_FAILURE';
export const ADD_CONTENT_VIEW_FILTER_RULE = 'ADD_CONTENT_VIEW_FILTER_RULE';
export const EDIT_CONTENT_VIEW_FILTER_RULE = 'EDIT_CONTENT_VIEW_FILTER_RULE';
export const REMOVE_CONTENT_VIEW_FILTER_RULE = 'REMOVE_CONTENT_VIEW_FILTER_RULE';
export const EDIT_CONTENT_VIEW_FILTER = 'EDIT_CONTENT_VIEW_FILTER';
export const ACTIVATION_KEY_KEY = 'ACTIVATION_KEY_KEY';
export const HOSTS_KEY = 'HOSTS_KEY';
export const RPM_PACKAGE_GROUPS_CONTENT = 'RPM_PACKAGE_GROUPS_CONTENT';
export const REPOSITORY_CONTENT = 'REPOSITORY_CONTENT';
export const ERRATA_CONTENT = 'ERRATA_CONTENT';
export const DOCKER_TAGS_CONTENT = 'DOCKER_TAGS_CONTENT';
export const MODULE_STREAMS_CONTENT = 'MODULE_STREAMS_CONTENT';
export const DEB_PACKAGES_CONTENT = 'DEB_PACKAGES_CONTENT';
export const RPM_PACKAGES_CONTENT = 'RPM_PACKAGES_CONTENT';
export const FILE_CONTENT = 'FILE_CONTENT';
export const generatedContentKey = pluralLabel => `${toUpper(pluralLabel)}_CONTENT`;
export const cvDetailsKey = cvId => `${CONTENT_VIEWS_KEY}_${cvId}`;
export const cvDetailsRepoKey = cvId => `${CONTENT_VIEWS_KEY}_REPOSITORIES_${cvId}`;
export const cvFilterRepoKey = filterId => `CV_FILTER_REPOSITORIES_${filterId}`;
export const cvDetailsFiltersKey = cvId => `${CONTENT_VIEWS_KEY}_FILTERS_${cvId}`;
export const cvFilterDetailsKey = (cvId, filterId) => `${CONTENT_VIEWS_KEY}_${cvId}_FILTER_${filterId}`;
export const cvFilterPackageGroupsKey =
  (cvId, filterId) => `${CONTENT_VIEWS_KEY}_${cvId}_FILTER_${filterId}_PACKAGE_GROUPS`;
export const cvFilterModuleStreamKey =
  (cvId, filterId) => `${CONTENT_VIEWS_KEY}_${cvId}_FILTER_${filterId}_MODULE_STREAMS`;
export const cvFilterErratumIDKey =
  (cvId, filterId) => `${CONTENT_VIEWS_KEY}_${cvId}_FILTER_${filterId}_ERRATA`;
export const cvDetailsHistoryKey = cvId => `${CONTENT_VIEWS_KEY}_HISTORIES_${cvId}`;
export const cvFilterRulesKey = filterId => `CONTENT_VIEW_FILTER_${filterId}_RULES`;
export const cvDetailsComponentKey = cvId => `${CONTENT_VIEWS_KEY}_COMPONENTS_${cvId}`;
export const cvDetailsVersionKey = cvId => `${CONTENT_VIEWS_KEY}_VERSIONS_${cvId}`;
export const bulkRemoveVersionKey = cvId => `BULK_REMOVE_CV_VERSION_${cvId}`;
export const cvRemoveVersionKey = (versionId, versionEnvironments) => `REMOVE_CV_VERSION_${versionId}_${versionEnvironments.length}`;
export const cvVersionPromoteKey = (versionId, environmentIds) => `PROMOTE_CONTENT_VIEW_VERSION_${versionId}_${environmentIds.length}`;
export const cvVersionDetailsKey = (cvId, versionId) => `CONTENT_VIEW_VERSION_DETAILS_${cvId}_${versionId}`;
export const cvVersionPublishKey = (cvId, versionCount) => `${PUBLISH_CONTENT_VIEW_KEY}_${cvId}_VERSION_${versionCount}`;
export const cvVersionTaskPollingKey = cvId => `CONTENT_VIEW_VERSION_POLLING_${cvId}`;
export const cvAddComponentKey = cvId => `${CONTENT_VIEWS_KEY}_ADD_COMPONENT_${cvId}`;
export const cvRemoveComponentKey = cvId => `${CONTENT_VIEWS_KEY}_REMOVE_COMPONENT_${cvId}`;

export const removeComponentSuccessMessage = size => (size === 1 ? __('Removed component from content view') : __('Removed components from content view'));

export const addComponentSuccessMessage = component => (component ? __('Updated component details') : __('Added component to content view'));


// Repo added to content view status display and key
export const ADDED = __('Added');
export const NOT_ADDED = __('Not added');
export const ALL_STATUSES = __('All');

export const STATUS_TRANSLATIONS_ENUM = {
  [ADDED]: 'Added',
  [NOT_ADDED]: 'Not added',
  [ALL_STATUSES]: 'All',
};

export const REPOSITORY_TYPES = 'REPOSITORY_TYPES';
export const FILTER_TYPES = ['rpm', 'package_group', 'erratum_date', 'erratum_id', 'docker', 'modulemd'];

export const ERRATA_TYPES = ['enhancement', 'security', 'bugfix'];

export default CONTENT_VIEWS_KEY;
