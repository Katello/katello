import {
  ENABLED_REPOSITORIES_REQUEST,
  ENABLED_REPOSITORIES_SUCCESS,
  ENABLED_REPOSITORIES_FAILURE,
} from '../../consts';

const initialState = { isLoading: true };

export default (state = initialState, action) => {
  switch (action.type) {
    case ENABLED_REPOSITORIES_REQUEST:
      return { ...state, ...{ isLoading: true } };

    case ENABLED_REPOSITORIES_SUCCESS:
      return {
        ...state,
        ...{
          results: action.response.results,
          isLoading: false,
          success: true,
        },
      };

    case ENABLED_REPOSITORIES_FAILURE:
      return { ...state, ...{ results: action.result, isLoading: false, success: false } };

    default:
      return state;
  }
};
