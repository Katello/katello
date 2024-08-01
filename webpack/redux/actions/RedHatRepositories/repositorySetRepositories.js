import PropTypes from 'prop-types';
import api from '../../../services/api';
import { apiError, apiSuccess } from '../../../utils/helpers.js';
import { getArchFromPath } from './helpers.js';

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
    arch: repo.substitutions.basearch,
    releasever: repo.substitutions.releasever,
    displayArch: repo.substitutions.basearch || getArchFromPath(repo.path),
    enabled: repo.enabled,
    error: false,
    loading: false,
  }));
}

export const enableRepository = repository => async (dispatch) => {
  const {
    productId, contentId, arch, releasever,
  } = repository;

  const repoData = {
    id: contentId,
    product_id: productId,
    basearch: arch,
    releasever,
  };

  dispatch({ type: ENABLE_REPOSITORY_REQUEST, repository });

  const url = `/products/${productId}/repository_sets/${contentId}/enable`;
  try {
    const result = await api.put(url, repoData);
    return dispatch(apiSuccess(ENABLE_REPOSITORY_SUCCESS, result));
  } catch (error) {
    return dispatch(apiError(ENABLE_REPOSITORY_FAILURE, error, { repository }));
  }
};

const loadRepositorySetRepos = (contentId, productId) => async (dispatch) => {
  dispatch({
    type: REPOSITORY_SET_REPOSITORIES_REQUEST,
    contentId,
  });

  try {
    const { data } = await api.get(`/products/${productId}/repository_sets/${contentId}/available_repositories`);
    return dispatch({
      type: REPOSITORY_SET_REPOSITORIES_SUCCESS,
      contentId,
      productId,
      results: data.results,
    });
  } catch (error) {
    return dispatch(apiError(
      REPOSITORY_SET_REPOSITORIES_FAILURE,
      error,
      { contentId },
    ));
  }
};

loadRepositorySetRepos.propTypes = {
  data: PropTypes.shape({
    error: PropTypes.shape({
      displayMessage: PropTypes.string,
    }),
  }),
};

export default loadRepositorySetRepos;
