import axios from 'axios';

import {
  ENABLED_REPOSITORIES_REQUEST,
  ENABLED_REPOSITORIES_SUCCESS,
  ENABLED_REPOSITORIES_FAILURE,
} from '../../consts';

// eslint-disable-next-line import/prefer-default-export
export const loadEnabledRepos = () => (dispatch) => {
  dispatch({ type: ENABLED_REPOSITORIES_REQUEST });

  axios
    .get('/organizations/1/repository_sets?enabled=true')
    .then(({ data }) => {
      dispatch({
        type: ENABLED_REPOSITORIES_SUCCESS,
        response: data,
      });
    })
    .catch((result) => {
      dispatch({
        type: ENABLED_REPOSITORIES_FAILURE,
        result,
      });
    });
};
