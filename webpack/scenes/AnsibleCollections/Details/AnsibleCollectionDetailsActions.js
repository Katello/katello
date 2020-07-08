import api, { orgId } from '../../../services/api';
import {
  ANSIBLE_COLLECTION_DETAILS_ERROR,
  ANSIBLE_COLLECTION_DETAILS_REQUEST,
  ANSIBLE_COLLECTION_DETAILS_SUCCESS,
} from './AnsibleCollectionDetailsConstants';
import { apiError } from '../../../utils/helpers';

export const getAnsibleCollectionDetails = ansibleCollectionId => async (dispatch) => {
  dispatch({ type: ANSIBLE_COLLECTION_DETAILS_REQUEST });

  try {
    const { data } = await api.get(`/ansible_collections/${ansibleCollectionId}`, {}, { organization_id: orgId() });
    return dispatch({
      type: ANSIBLE_COLLECTION_DETAILS_SUCCESS,
      response: data,
    });
  } catch (error) {
    return dispatch(apiError(ANSIBLE_COLLECTION_DETAILS_ERROR, error));
  }
};

export default getAnsibleCollectionDetails;
