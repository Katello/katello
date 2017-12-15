import axios from 'axios';

import {
  REPOSITORY_SET_REPOSITORIES_REQUEST,
  REPOSITORY_SET_REPOSITORIES_SUCCESS,
  REPOSITORY_SET_REPOSITORIES_FAILURE,
  REPOSITORY_ENABLED,
} from '../../consts';

export const setRepositoryEnabled = repository => ({
  type: REPOSITORY_ENABLED,
  repository,
});

export function normalizeContentSetRepositories(repos, contentId, productId) {
  return repos.map(repo => ({
    contentId,
    productId,
    arch: repo.substitutions.basearch,
    releasever: repo.substitutions.releasever,
    enabled: false,
  }));
}

const loadRepositorySetRepos = (contentId, productId) => (dispatch) => {
  dispatch({
    type: REPOSITORY_SET_REPOSITORIES_REQUEST,
    contentId,
  });

  axios
    .get(`/products/${productId}/repository_sets/${contentId}/available_repositories`)
    .then(({ data }) => {
      dispatch({
        type: REPOSITORY_SET_REPOSITORIES_SUCCESS,
        contentId,
        productId,
        results: data.results,
      });
    })
    .catch((result) => {
      dispatch({
        type: REPOSITORY_SET_REPOSITORIES_FAILURE,
        contentId,
        result,
      });
    });
};

export default loadRepositorySetRepos;
