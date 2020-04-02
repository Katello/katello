import { propsToSnakeCase } from 'foremanReact/common/helpers';

import { isEmpty } from 'lodash';
import api, { orgId } from '../../services/api';

import {
  CONTENT_VIEWS_REQUEST,
  CONTENT_VIEWS_SUCCESS,
  CONTENT_VIEWS_FAILURE,
} from './ContentViewConstants';

import { apiError } from '../../move_to_foreman/common/helpers.js';

export const createContentViewsParams = (extendedParams = {}) => ({
  ...{
    organization_id: orgId(),
    include_permissions: true,
  },
  ...propsToSnakeCase(extendedParams),
});

export const loadContentViews = (extendedParams = {}) => async (dispatch) => {
  dispatch({ type: CONTENT_VIEWS_REQUEST });

  const params = createContentViewsParams(extendedParams);

  try {
    const { data } = await api.get('/content_views', {}, params);
    const result = dispatch({
      type: CONTENT_VIEWS_SUCCESS,
      response: data,
      search: extendedParams.search,
    });
    const poolIds = filterRHContentViews(data.results).map(subs => subs.id);
    if (poolIds.length > 0) {
      dispatch(loadAvailableQuantities({ poolIds }));
    }
    return result;
  } catch (error) {
    return dispatch(apiError(CONTENT_VIEWS_FAILURE, error));
  }
};

export default loadContentViews;
