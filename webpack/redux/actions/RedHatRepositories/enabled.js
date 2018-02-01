import axios from 'axios';

import {
  ENABLED_REPOSITORIES_REQUEST,
  ENABLED_REPOSITORIES_SUCCESS,
  ENABLED_REPOSITORIES_FAILURE,
  REPOSITORY_DISABLED,
} from '../../consts';

export const setRepositoryDisabled = repository => ({
  type: REPOSITORY_DISABLED,
  repository,
});

export const loadEnabledRepos = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: ENABLED_REPOSITORIES_REQUEST });

  const params = { ...{ organization_id: orgId, enabled: 'true' }, ...extendedParams };

  api
    .get('/repository_sets', {}, params)
    .then(({ data }) => {
      dispatch({
        type: ENABLED_REPOSITORIES_SUCCESS,
        response: data,
        search: extendedParams.search,
      });
    })
    .catch((result) => {
      dispatch({
        type: ENABLED_REPOSITORIES_FAILURE,
        result,
      });
    });
};
