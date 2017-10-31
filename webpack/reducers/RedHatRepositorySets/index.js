import Immutable from 'seamless-immutable';
import merge from 'lodash/merge';

import {
  REDHAT_REPOSITORY_SETS_REQUEST, REDHAT_REPOSITORY_SETS_SUCCESS, REDHAT_REPOSITORY_SETS_FAILURE
} from '../../actions/RedHatRepositorySets';

const redHatRepositorySets = (state = Immutable({}), action) => {
  switch (action.type) {
    case REDHAT_REPOSITORY_SETS_REQUEST:
      return merge(state, { isLoading: true });
    case REDHAT_REPOSITORY_SETS_SUCCESS:
      return merge(action.response, state, { isLoading: false });
    case REDHAT_REPOSITORY_SETS_FAILURE:
      return merge(action.result, state, { isLoading: false });
    default:
      return state;
  }
};

export default redHatRepositorySets;