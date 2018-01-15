import api, { orgId } from '../../../services/api';
import {
  REPOSITORY_SETS_REQUEST,
  REPOSITORY_SETS_SUCCESS,
  REPOSITORY_SETS_FAILURE,
} from '../../consts';

// eslint-disable-next-line import/prefer-default-export
export const loadRepositorySets = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: REPOSITORY_SETS_REQUEST });

  const params = { ...{ organization_id: orgId }, ...extendedParams };

  api
    .get('/repository_sets', {}, params)
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
