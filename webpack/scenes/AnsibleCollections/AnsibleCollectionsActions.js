import { propsToSnakeCase } from 'foremanReact/common/helpers';

import api, { orgId } from '../../services/api';
import {
  ANSIBLE_COLLECTIONS_REQUEST,
  ANSIBLE_COLLECTIONS_SUCCESS,
  ANSIBLE_COLLECTIONS_ERROR,
} from './AnsibleCollectionsConstants';
import { apiError } from '../../move_to_foreman/common/helpers';

export const getAnsibleCollections = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: ANSIBLE_COLLECTIONS_REQUEST });

  const params = {
    organization_id: orgId(),
    ...propsToSnakeCase(extendedParams),
  };

  return api
    .get('/ansible_collections', {}, params)
    .then(({ data }) => {
      dispatch({
        type: ANSIBLE_COLLECTIONS_SUCCESS,
        response: data,
      });
    })
    .catch(result => dispatch(apiError(ANSIBLE_COLLECTIONS_ERROR, result)));
};

export default getAnsibleCollections;

