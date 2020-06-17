import { API_OPERATIONS, get, put } from 'foremanReact/redux/API';
import { addToast } from 'foremanReact/redux/actions/toasts';
import { translate as __ } from 'foremanReact/common/I18n';

import CONTENT_VIEWS_KEY, {
  UPDATE_CONTENT_VIEW,
  UPDATE_CONTENT_VIEW_FAILURE,
  UPDATE_CONTENT_VIEW_SUCCESS,
} from '../ContentViewsConstants';
import api from '../../../services/api';

import { apiError } from '../../../move_to_foreman/common/helpers';

const getContentViewDetails = cvId => get({
  type: API_OPERATIONS.GET,
  key: `${CONTENT_VIEWS_KEY}_${cvId}`,
  url: api.getApiUrl(`/content_views/${cvId}`),
});

const cvUpdateSuccess = (response, dispatch) => {
  const { data: { id } } = response;
  // Update CV info in redux with the updated CV info from API
  dispatch(getContentViewDetails(id));
  return dispatch(addToast({
    type: 'success',
    message: __(' Content View updated.'),
  }));
};

export const updateContentView = (cvId, params) => async dispatch => dispatch(put({
  type: API_OPERATIONS.PUT,
  key: `${CONTENT_VIEWS_KEY}_${cvId}`,
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

export default getContentViewDetails;
