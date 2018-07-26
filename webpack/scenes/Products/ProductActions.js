import api, { orgId } from '../../services/api';

import {
  PRODUCTS_REQUEST,
  PRODUCTS_SUCCESS,
  PRODUCTS_FAILURE,
} from './ProductConstants';
import { apiError } from '../../move_to_foreman/common/helpers.js';

export const loadProducts = (params = {}) => (dispatch) => {
  dispatch({ type: PRODUCTS_REQUEST });

  return api
    .get(`/organizations/${orgId()}/products/`, {}, params)
    .then(({ data }) => {
      dispatch({
        type: PRODUCTS_SUCCESS,
        response: data,
      });
    })
    .catch(result => dispatch(apiError(PRODUCTS_FAILURE, result)));
};

export default loadProducts;
