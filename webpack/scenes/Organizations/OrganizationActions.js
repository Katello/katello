import api, { orgId } from '../../services/api';
import { propsToSnakeCase } from '../../services/index';

import {
  GET_ORGANIZATION_REQUEST,
  GET_ORGANIZATION_SUCCESS,
  GET_ORGANIZATION_FAILURE,
  SAVE_ORGANIZATION_REQUEST,
  SAVE_ORGANIZATION_SUCCESS,
  SAVE_ORGANIZATION_FAILURE,
} from './OrganizationConstants';

export const loadOrganization = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: GET_ORGANIZATION_REQUEST });

  const params = {
    ...propsToSnakeCase(extendedParams),
  };

  return api
    .get(`/organizations/${orgId()}`, {}, params)
    .then(({ data }) => {
      dispatch({
        type: GET_ORGANIZATION_SUCCESS,
        response: data,
      });
    })
    .catch((result) => {
      dispatch({
        type: GET_ORGANIZATION_FAILURE,
        result,
      });
    });
};

export const saveOrganization = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: SAVE_ORGANIZATION_REQUEST });

  const params = {
    ...{ id: orgId() },
    ...propsToSnakeCase(extendedParams),
  };

  return api
    .put(`/organizations/${orgId()}`, params)
    .then(({ data }) => {
      dispatch({
        type: SAVE_ORGANIZATION_SUCCESS,
        response: data,
      });
    })
    .catch((result) => {
      dispatch({
        type: SAVE_ORGANIZATION_FAILURE,
        result,
      });
    });
};

export default loadOrganization;
