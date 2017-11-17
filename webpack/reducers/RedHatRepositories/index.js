import {
  REDHAT_REPOSITORIES_REQUEST,
  REDHAT_REPOSITORIES_SUCCESS,
  REDHAT_REPOSITORIES_FAILURE,
} from '../../actions/RedHatRepositories';

const redHatRepositories = (state = {}, action) => {
  switch (action.type) {
    case REDHAT_REPOSITORIES_REQUEST:
      return Object.assign(state, { isLoading: true });
    case REDHAT_REPOSITORIES_SUCCESS:
      return Object.assign(action.response, state, { isLoading: false });
    case REDHAT_REPOSITORIES_FAILURE:
      return Object.assign(action.result, state, { isLoading: false });
    default:
      return state;
  }
};

export default redHatRepositories;
