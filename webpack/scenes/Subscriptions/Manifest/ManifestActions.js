import { API_OPERATIONS, get, put, post } from 'foremanReact/redux/API';
import { propsToSnakeCase } from 'foremanReact/common/helpers';
import api, { orgId } from '../../../services/api';
import { getResponseErrorMsgs } from '../../../utils/helpers.js';

import {
  UPLOAD_MANIFEST_REQUEST,
  UPLOAD_MANIFEST_SUCCESS,
  UPLOAD_MANIFEST_FAILURE,
  REFRESH_MANIFEST_REQUEST,
  REFRESH_MANIFEST_SUCCESS,
  REFRESH_MANIFEST_FAILURE,
  DELETE_MANIFEST_REQUEST,
  DELETE_MANIFEST_SUCCESS,
  DELETE_MANIFEST_FAILURE,
  MANIFEST_HISTORY_REQUEST,
  MANIFEST_HISTORY_SUCCESS,
  MANIFEST_HISTORY_FAILURE,
  UPLOAD_MANIFEST_KEY,
  REFRESH_MANIFEST_KEY,
  DELETE_MANIFEST_KEY,
  MANIFEST_HISTORY_KEY,
} from './ManifestConstants';

const manifestErrorToast = error => getResponseErrorMsgs(error.response);

export const uploadManifest = (file, handleSuccess) => {
  const formData = new FormData();
  formData.append('content', file);

  return post({
    type: API_OPERATIONS.POST,
    key: UPLOAD_MANIFEST_KEY,
    url: api.getApiUrl(`/organizations/${orgId()}/subscriptions/upload`),
    params: formData,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    handleSuccess,
    errorToast: manifestErrorToast,
    actionTypes: {
      REQUEST: UPLOAD_MANIFEST_REQUEST,
      SUCCESS: UPLOAD_MANIFEST_SUCCESS,
      FAILURE: UPLOAD_MANIFEST_FAILURE,
    },
  });
};

export const refreshManifest = (extendedParams = {}, handleSuccess) => put({
  type: API_OPERATIONS.PUT,
  key: REFRESH_MANIFEST_KEY,
  url: api.getApiUrl(`/organizations/${orgId()}/subscriptions/refresh_manifest`),
  params: propsToSnakeCase(extendedParams),
  handleSuccess,
  errorToast: manifestErrorToast,
  actionTypes: {
    REQUEST: REFRESH_MANIFEST_REQUEST,
    SUCCESS: REFRESH_MANIFEST_SUCCESS,
    FAILURE: REFRESH_MANIFEST_FAILURE,
  },
});

export const deleteManifest = (extendedParams = {}, handleSuccess) => post({
  type: API_OPERATIONS.POST,
  key: DELETE_MANIFEST_KEY,
  url: api.getApiUrl(`/organizations/${orgId()}/subscriptions/delete_manifest`),
  params: propsToSnakeCase(extendedParams),
  handleSuccess,
  errorToast: manifestErrorToast,
  actionTypes: {
    REQUEST: DELETE_MANIFEST_REQUEST,
    SUCCESS: DELETE_MANIFEST_SUCCESS,
    FAILURE: DELETE_MANIFEST_FAILURE,
  },
});

export const loadManifestHistory = (extendedParams = {}) => get({
  type: API_OPERATIONS.GET,
  key: MANIFEST_HISTORY_KEY,
  url: api.getApiUrl(`/organizations/${orgId()}/subscriptions/manifest_history`),
  params: propsToSnakeCase(extendedParams),
  errorToast: manifestErrorToast,
  actionTypes: {
    REQUEST: MANIFEST_HISTORY_REQUEST,
    SUCCESS: MANIFEST_HISTORY_SUCCESS,
    FAILURE: MANIFEST_HISTORY_FAILURE,
  },
});

export default loadManifestHistory;
