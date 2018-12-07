import api from '../../../services/api';
import { apiError, apiSuccess } from '../../../move_to_foreman/common/helpers.js';

import {
  REPOSITORY_SET_REPOSITORIES_REQUEST,
  REPOSITORY_SET_REPOSITORIES_SUCCESS,
  REPOSITORY_SET_REPOSITORIES_FAILURE,
  ENABLE_REPOSITORY_REQUEST,
  ENABLE_REPOSITORY_SUCCESS,
  ENABLE_REPOSITORY_FAILURE,
  REPOSITORY_ENABLED,
} from '../../consts';

export const setRepositoryEnabled = repository => ({
  type: REPOSITORY_ENABLED,
  repository,
});

export function normalizeContentSetRepositories(repos, contentId, productId) {
  return repos.map(repo => ({
    contentId: parseInt(contentId, 10),
    productId: parseInt(productId, 10),
    archDisplay: repo.arch,
    archSubstitution: repo.substitutions.basearch,
    releasever: repo.substitutions.releasever,
    enabled: repo.enabled,
    error: false,
    loading: false,
  }));
}

export const enableRepository = repository => (dispatch) => {
  const {
    productId, contentId, archSubstitution, releasever,
  } = repository;

  const repoData = {
    id: contentId,
    product_id: productId,
    basearch: archSubstitution,
    releasever,
  };

  dispatch({ type: ENABLE_REPOSITORY_REQUEST, repository });

  const url = `/products/${productId}/repository_sets/${contentId}/enable`;
  return api
    .put(url, repoData)
    .then(result => dispatch(apiSuccess(ENABLE_REPOSITORY_SUCCESS, result)))
    .catch(result => dispatch(apiError(ENABLE_REPOSITORY_FAILURE, result, { repository })));
};

const loadRepositorySetRepos = (contentId, productId) => (dispatch) => {
  dispatch({
    type: REPOSITORY_SET_REPOSITORIES_REQUEST,
    contentId,
  });

  api
    .get(`/products/${productId}/repository_sets/${contentId}/available_repositories`)
    .then(({ data }) => {
      dispatch({
        type: REPOSITORY_SET_REPOSITORIES_SUCCESS,
        contentId,
        productId,
        results: data.results,
      });
    })
    .catch(({ response: { data: error } }) => {
      dispatch({
        type: REPOSITORY_SET_REPOSITORIES_FAILURE,
        contentId,
        error,
      });
    });
};

export default loadRepositorySetRepos;
