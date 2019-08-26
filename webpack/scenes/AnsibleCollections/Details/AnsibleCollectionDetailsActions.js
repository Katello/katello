import api from '../../../services/api';
import {
  ANSIBLE_COLLECTION_DETAILS_ERROR,
  ANSIBLE_COLLECTION_DETAILS_REQUEST,
  ANSIBLE_COLLECTION_DETAILS_SUCCESS,
} from './AnsibleCollectionDetailsConstants';
import { apiError } from '../../../move_to_foreman/common/helpers';

export const getAnsibleCollectionDetails = ansibleCollectionId => (dispatch) => {
  dispatch({ type: ANSIBLE_COLLECTION_DETAILS_REQUEST });

  return api
    .get(`/ansible_collections/${ansibleCollectionId}`)
    .then(({ data }) => {
      dispatch({
        type: ANSIBLE_COLLECTION_DETAILS_SUCCESS,
        response: data,
      });
    })
    .catch((result) => {
      dispatch(apiError(ANSIBLE_COLLECTION_DETAILS_ERROR, result));
    });
};

export default getAnsibleCollectionDetails;
