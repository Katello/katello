import api, { orgId } from '../../../services/api';
import { propsToSnakeCase } from '../../../services/index';
import { apiError } from '../../../move_to_foreman/common/helpers.js';

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
} from './ManifestConstants';

export const uploadManifest = file => (dispatch) => {
  dispatch({ type: UPLOAD_MANIFEST_REQUEST });

  const formData = new FormData();
  formData.append('content', file);

  const config = {
    'Content-Type': 'multipart/form-data',
  };

  return api
    .post(`/organizations/${orgId()}/subscriptions/upload`, formData, config)
    .then(({ data }) => {
      dispatch({
        type: UPLOAD_MANIFEST_SUCCESS,
        response: data,
      });
    })
    .catch(result => dispatch(apiError(UPLOAD_MANIFEST_FAILURE, result)));
};

export const refreshManifest = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: REFRESH_MANIFEST_REQUEST });

  const params = {
    ...propsToSnakeCase(extendedParams),
  };

  return api
    .put(`/organizations/${orgId()}/subscriptions/refresh_manifest`, {}, params)
    .then(({ data }) => {
      dispatch({
        type: REFRESH_MANIFEST_SUCCESS,
        response: data,
      });
    })
    .catch(result => dispatch(apiError(REFRESH_MANIFEST_FAILURE, result)));
};

export const deleteManifest = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: DELETE_MANIFEST_REQUEST });

  const params = {
    ...propsToSnakeCase(extendedParams),
  };

  return api
    .post(`/organizations/${orgId()}/subscriptions/delete_manifest`, {}, params)
    .then(({ data }) => {
      dispatch({
        type: DELETE_MANIFEST_SUCCESS,
        response: data,
      });
    })
    .catch(result => dispatch(apiError(DELETE_MANIFEST_FAILURE, result)));
};

export const loadManifestHistory = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: MANIFEST_HISTORY_REQUEST });

  const params = {
    ...propsToSnakeCase(extendedParams),
  };

  return api
    .get(`/organizations/${orgId()}/subscriptions/manifest_history`, {}, params)
    .then(({ data }) => {
      dispatch({
        type: MANIFEST_HISTORY_SUCCESS,
        response: data,
      });
    })
    .catch(result => dispatch(apiError(MANIFEST_HISTORY_FAILURE, result)));
};

export default loadManifestHistory;
