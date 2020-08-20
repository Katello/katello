import { API_OPERATIONS, get, put } from 'foremanReact/redux/API';
import { addToast } from 'foremanReact/redux/actions/toasts';
import { translate as __ } from 'foremanReact/common/I18n';

import {
  UPDATE_CONTENT_VIEW,
  UPDATE_CONTENT_VIEW_FAILURE,
  UPDATE_CONTENT_VIEW_SUCCESS,
  NOT_ADDED,
  ADDED,
  cvDetailsKey,
  cvDetailsRepoKey,
} from '../ContentViewsConstants';
import api from '../../../services/api';

import { apiError } from '../../../utils/helpers';

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
    message: __(' Content view updated.'),
  }));
};

export const updateContentView = (cvId, params) => async dispatch => dispatch(put({
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

export const getContentViewRepositories = (cvId, params, status) => {
  const apiParams = { ...params };
  let apiUrl = `/content_views/${cvId}/repositories`;
  if (status[ADDED] && status[NOT_ADDED]) {
    apiUrl += '/show_all';
  } else if (status[NOT_ADDED]) {
    apiParams.available_for = 'content_view';
  }

  return get({
    type: API_OPERATIONS.GET,
    key: cvDetailsRepoKey(cvId),
    url: api.getApiUrl(apiUrl),
    apiParams,
  });
};

export default getContentViewDetails;
