import { initialApiState } from '../../../services/api';
import {
  ANSIBLE_COLLECTION_DETAILS_REQUEST,
  ANSIBLE_COLLECTION_DETAILS_SUCCESS,
  ANSIBLE_COLLECTION_DETAILS_ERROR,
} from './AnsibleCollectionDetailsConstants';

export default (state = initialApiState, action) => {
  switch (action.type) {
  case ANSIBLE_COLLECTION_DETAILS_REQUEST: {
    return state.set('loading', true);
  }
  case ANSIBLE_COLLECTION_DETAILS_SUCCESS: {
    const ansibleCollectionDetails = action.response;
    return state.merge({
      ...ansibleCollectionDetails,
      loading: false,
    });
  }
  case ANSIBLE_COLLECTION_DETAILS_ERROR: {
    return state.merge({
      error: action.payload.message,
      loading: false,
    });
  }
  default: {
    return state;
  }
  }
};
