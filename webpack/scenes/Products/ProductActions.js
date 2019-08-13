import api, { orgId } from '../../services/api';

import {
  PRODUCTS_REQUEST,
  PRODUCTS_SUCCESS,
  PRODUCTS_FAILURE,
} from './ProductConstants';
import { apiError } from '../../move_to_foreman/common/helpers.js';

export const loadProducts = (params = {}) => async (dispatch) => {
  dispatch({ type: PRODUCTS_REQUEST });

  try {
    const { data } = await api.get(`/organizations/${orgId()}/products/`, {}, params);
    return dispatch({
      type: PRODUCTS_SUCCESS,
      response: data,
    });
  } catch (error) {
    return dispatch(apiError(PRODUCTS_FAILURE, error));
  }
};

export default loadProducts;
