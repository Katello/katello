import api from '../../../services/api';
import {
  ANSIBLE_COLLECTION_DETAILS_ERROR,
  ANSIBLE_COLLECTION_DETAILS_REQUEST,
  ANSIBLE_COLLECTION_DETAILS_SUCCESS,
} from './AnsibleCollectionDetailsConstants';
import { apiError } from '../../../move_to_foreman/common/helpers';

export const getAnsibleCollectionDetails = ansibleCollectionId => async (dispatch) => {
  dispatch({ type: ANSIBLE_COLLECTION_DETAILS_REQUEST });

  try {
    const { data } = await api.get(`/ansible_collections/${ansibleCollectionId}`);
    return dispatch({
      type: ANSIBLE_COLLECTION_DETAILS_SUCCESS,
      response: data,
    });
  } catch (error) {
    return dispatch(apiError(ANSIBLE_COLLECTION_DETAILS_ERROR, error));
  }
};

export default getAnsibleCollectionDetails;
