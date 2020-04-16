import { propsToSnakeCase } from 'foremanReact/common/helpers';

import api, { orgId } from '../../services/api';
import {
  CONTENT_VIEWS_REQUEST,
  CONTENT_VIEWS_SUCCESS,
  CONTENT_VIEWS_FAILURE,
  CONTENT_VIEW_DETAILS_REQUEST,
  CONTENT_VIEW_DETAILS_SUCCESS,
  CONTENT_VIEW_DETAILS_FAILURE,
} from './ContentViewsConstants';
import { apiError } from '../../move_to_foreman/common/helpers.js';

const createContentViewsParams = (extendedParams = {}) => ({
  ...{
    organization_id: orgId(),
    nondefault: true,
  },
  ...propsToSnakeCase(extendedParams),
});

export const loadContentViews = (extendedParams = {}) => async (dispatch) => {
  dispatch({ type: CONTENT_VIEWS_REQUEST });

  const params = createContentViewsParams(extendedParams);

  try {
    const { data } = await api.get('/content_views', {}, params);
    return dispatch({
      type: CONTENT_VIEWS_SUCCESS,
      response: data,
      search: extendedParams.search,
    });
  } catch (error) {
    return dispatch(apiError(CONTENT_VIEWS_FAILURE, error));
  }
};

export const loadContentViewDetails = contentViewId => async (dispatch) => {
  dispatch({
    contentViewId,
    type: CONTENT_VIEW_DETAILS_REQUEST,
  });

  try {
    const { data } = await api.get(`/content_views/${contentViewId}`);
    return dispatch({
      type: CONTENT_VIEW_DETAILS_SUCCESS,
      response: data,
      contentViewId,
    });
  } catch (error) {
    return dispatch({ contentViewId, ...apiError(CONTENT_VIEW_DETAILS_FAILURE, error) });
  }
};
