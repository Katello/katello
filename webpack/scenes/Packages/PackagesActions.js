import api, { orgId } from '../../services/api';
import {
  PACKAGES_REQUEST,
  PACKAGES_SUCCESS,
  PACKAGES_FAILURE,
} from './PackagesConstants';
import { getResponseError } from '../../move_to_foreman/common/helpers.js';
import { propsToSnakeCase } from '../../services/index';

export const getPackages = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: PACKAGES_REQUEST });

  const params = {
    ...{ organization_id: orgId },
    ...propsToSnakeCase(extendedParams),
  };

  return api
    .get(`/packages`, {}, params)
    .then(({ data }) => {
      dispatch({
        type: PACKAGES_SUCCESS,
        response: data,
      });
    })
    .catch((result) => {
      dispatch({
        type: PACKAGES_FAILURE,
        error: getResponseError(result.response),
      });
    });
};

export default getPackages;
