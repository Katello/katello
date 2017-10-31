import Immutable from 'seamless-immutable';
import merge from 'lodash/merge';

import {
  REDHAT_REPOSITORIES_REQUEST, REDHAT_REPOSITORIES_SUCCESS, REDHAT_REPOSITORIES_FAILURE
} from '../../actions/RedHatRepositories';

const redHatRepositories = (state = Immutable({}), action) => {
  switch (action.type) {
    case REDHAT_REPOSITORIES_REQUEST:
      return merge(state, { isLoading: true });
    case REDHAT_REPOSITORIES_SUCCESS:
      return merge(action.response, state, { isLoading: false });
    case REDHAT_REPOSITORIES_FAILURE:
      return merge(action.result, state, { isLoading: false });
    default:
      return state;
  }
};

export default redHatRepositories;