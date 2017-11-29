import axios from 'axios';

import {
  REPOSITORY_SETS_REQUEST,
  REPOSITORY_SETS_SUCCESS,
  REPOSITORY_SETS_FAILURE,
} from '../../consts';

// eslint-disable-next-line import/prefer-default-export
export const loadRepositorySets = () => (dispatch) => {
  dispatch({ type: REPOSITORY_SETS_REQUEST });

  axios
    .get('/organizations/1/repository_sets')
    .then(({ data }) => {
      dispatch({
        type: REPOSITORY_SETS_SUCCESS,
        response: data,
      });
    })
    .catch((result) => {
      dispatch({
        type: REPOSITORY_SETS_FAILURE,
        result,
      });
    });
};
