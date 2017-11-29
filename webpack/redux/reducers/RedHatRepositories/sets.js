import {
  REPOSITORY_SETS_REQUEST,
  REPOSITORY_SETS_SUCCESS,
  REPOSITORY_SETS_FAILURE,
} from '../../consts';

const initialState = { isLoading: true };

export default (state = initialState, action) => {
  switch (action.type) {
    case REPOSITORY_SETS_REQUEST:
      return Object.assign({}, state, { isLoading: true });

    case REPOSITORY_SETS_SUCCESS:
      return Object.assign({}, state, {
        results: action.response.results,
        isLoading: false,
        success: true,
      });

    case REPOSITORY_SETS_FAILURE:
      return Object.assign({}, { results: action.result, isLoading: false, success: false }, state);

    default:
      return state;
  }
};
