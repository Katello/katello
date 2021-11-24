import {
  selectAPIStatus,
  selectAPIResponse,
  selectAPIError,
} from 'foremanReact/redux/API/APISelectors';

import { CHANGE_CONTENT_SOURCE_DATA, CHANGE_CONTENT_SOURCE, CHANGE_CONTENT_SOURCE_VIEWS } from './constants';

// API statuses
export const selectApiDataStatus = state =>
  selectAPIStatus(state, CHANGE_CONTENT_SOURCE_DATA);

export const selectApiContentViewStatus = state =>
  selectAPIStatus(state, CHANGE_CONTENT_SOURCE_VIEWS);

export const selectApiChangeContentStatus = state =>
  selectAPIStatus(state, CHANGE_CONTENT_SOURCE);

export const selectError = state => selectAPIError(state, CHANGE_CONTENT_SOURCE);

// Selectors
export const selectContentHostsIds = state =>
  selectAPIResponse(state, CHANGE_CONTENT_SOURCE_DATA).content_hosts_ids || [];

export const selectHostsWithoutContent = state =>
  selectAPIResponse(state, CHANGE_CONTENT_SOURCE_DATA).hosts_without_content || [];

export const selectEnvironments = state =>
  selectAPIResponse(state, CHANGE_CONTENT_SOURCE_DATA).environments || [];

export const selectContentSources = state =>
  selectAPIResponse(state, CHANGE_CONTENT_SOURCE_DATA).content_sources || [];

export const selectJobInvocationPath = state =>
  selectAPIResponse(state, CHANGE_CONTENT_SOURCE_DATA).job_invocation_path;

export const selectContentViews = state =>
  selectAPIResponse(state, CHANGE_CONTENT_SOURCE_VIEWS).results || [];

export const selectTemplate = state =>
  selectAPIResponse(state, CHANGE_CONTENT_SOURCE) || '';

