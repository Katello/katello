import api, { orgId as getOrgId } from '../../services/api';

import {
  ORGANIZATION_PRODUCTS_REQUEST,
  ORGANIZATION_PRODUCTS_SUCCESS,
  ORGANIZATION_PRODUCTS_FAILURE,
} from './OrganizationProductsConstants';
import { apiError } from '../../move_to_foreman/common/helpers';

export const loadOrganizationProducts = (params = {}, orgId = getOrgId()) => (dispatch) => {
  dispatch({ type: ORGANIZATION_PRODUCTS_REQUEST });

  return api
    .get(`/organizations/${orgId}/products/`, {}, params)
    .then(({ data }) => {
      dispatch({
        type: ORGANIZATION_PRODUCTS_SUCCESS,
        payload: { orgId, ...data },
      });
    })
    .catch(result => dispatch(apiError(ORGANIZATION_PRODUCTS_FAILURE, result)));
};

export default loadOrganizationProducts;
