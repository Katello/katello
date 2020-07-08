import api, { orgId as getOrgId } from '../../services/api';

import {
  ORGANIZATION_PRODUCTS_REQUEST,
  ORGANIZATION_PRODUCTS_SUCCESS,
  ORGANIZATION_PRODUCTS_FAILURE,
} from './OrganizationProductsConstants';
import { apiError } from '../../utils/helpers';

export const loadOrganizationProducts = (params = {}, orgId = getOrgId()) => async (dispatch) => {
  dispatch({ type: ORGANIZATION_PRODUCTS_REQUEST });

  try {
    const { data } = await api.get(`/organizations/${orgId}/products/`, {}, params);
    return dispatch({
      type: ORGANIZATION_PRODUCTS_SUCCESS,
      payload: { orgId, ...data },
    });
  } catch (error) {
    return dispatch(apiError(ORGANIZATION_PRODUCTS_FAILURE, error));
  }
};

export default loadOrganizationProducts;
