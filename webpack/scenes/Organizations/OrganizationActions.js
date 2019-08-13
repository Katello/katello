import { propsToSnakeCase } from 'foremanReact/common/helpers';

import api, { orgId } from '../../services/api';

import {
  GET_ORGANIZATION_REQUEST,
  GET_ORGANIZATION_SUCCESS,
  GET_ORGANIZATION_FAILURE,
  SAVE_ORGANIZATION_REQUEST,
  SAVE_ORGANIZATION_SUCCESS,
  SAVE_ORGANIZATION_FAILURE,
} from './OrganizationConstants';

export const loadOrganization = (extendedParams = {}) => async (dispatch) => {
  dispatch({ type: GET_ORGANIZATION_REQUEST });

  const params = {
    ...propsToSnakeCase(extendedParams),
  };

  try {
    const { data } = await api.get(`/organizations/${orgId()}`, {}, params);
    return dispatch({
      type: GET_ORGANIZATION_SUCCESS,
      response: data,
    });
  } catch (error) {
    return dispatch({
      type: GET_ORGANIZATION_FAILURE,
      error,
    });
  }
};

export const saveOrganization = (extendedParams = {}) => async (dispatch) => {
  dispatch({ type: SAVE_ORGANIZATION_REQUEST });

  const params = {
    ...{ id: orgId() },
    ...propsToSnakeCase(extendedParams),
  };
  try {
    const { data } = await api.put(`/organizations/${orgId()}`, params);
    const result = dispatch({
      type: SAVE_ORGANIZATION_SUCCESS,
      response: data,
    });
    // TODO: Necessary because of https://projects.theforeman.org/issues/26420
    dispatch(loadOrganization());
    return result;
  } catch (error) {
    return dispatch({
      type: SAVE_ORGANIZATION_FAILURE,
      result: error,
    });
  }
};

export default loadOrganization;
