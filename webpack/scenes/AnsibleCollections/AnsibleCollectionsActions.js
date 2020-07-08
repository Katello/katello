import { propsToSnakeCase } from 'foremanReact/common/helpers';

import api, { orgId } from '../../services/api';
import {
  ANSIBLE_COLLECTIONS_REQUEST,
  ANSIBLE_COLLECTIONS_SUCCESS,
  ANSIBLE_COLLECTIONS_ERROR,
} from './AnsibleCollectionsConstants';
import { apiError } from '../../utils/helpers';

export const getAnsibleCollections = (extendedParams = {}) => async (dispatch) => {
  dispatch({ type: ANSIBLE_COLLECTIONS_REQUEST });

  const params = {
    organization_id: orgId(),
    ...propsToSnakeCase(extendedParams),
  };

  try {
    const { data } = await api.get('/ansible_collections', {}, params);
    return dispatch({
      type: ANSIBLE_COLLECTIONS_SUCCESS,
      response: data,
    });
  } catch (error) {
    return dispatch(apiError(ANSIBLE_COLLECTIONS_ERROR, error));
  }
};

export default getAnsibleCollections;
