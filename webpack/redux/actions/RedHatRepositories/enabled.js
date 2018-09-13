import api, { orgId } from '../../../services/api';
import {
  normalizeRepositorySets,
  repoTypeFilterToSearchQuery,
  productsIdsToSearchQuery,
  joinSearchQueries,
} from './helpers';
import { apiError, apiSuccess } from '../../../move_to_foreman/common/helpers.js';

import {
  ENABLED_REPOSITORIES_REQUEST,
  ENABLED_REPOSITORIES_SUCCESS,
  ENABLED_REPOSITORIES_FAILURE,
  DISABLE_REPOSITORY_REQUEST,
  DISABLE_REPOSITORY_SUCCESS,
  DISABLE_REPOSITORY_FAILURE,
  REPOSITORY_DISABLED,
} from '../../consts';
import { propsToSnakeCase } from '../../../services/index';

export const setRepositoryDisabled = repository => ({
  type: REPOSITORY_DISABLED,
  repository,
});

export const createEnabledRepoParams = (extendedParams = {}) => {
  const searchParams = extendedParams.search || {};
  const search = joinSearchQueries([
    'redhat = true',
    repoTypeFilterToSearchQuery(searchParams.filters || []),
    productsIdsToSearchQuery(searchParams.products || []),
    searchParams.query,
  ]);

  const repoParams = {
    ...{ organization_id: orgId(), enabled: 'true' },
    ...propsToSnakeCase(extendedParams),
    search,
  };

  return { searchParams, repoParams };
};

export const disableRepository = repository => (dispatch) => {
  const {
    productId, contentId, arch, releasever,
  } = repository;

  const repoData = {
    id: contentId,
    product_id: productId,
    basearch: arch,
    releasever,
  };

  dispatch({ type: DISABLE_REPOSITORY_REQUEST, repository });

  const url = `/products/${productId}/repository_sets/${contentId}/disable`;
  return api
    .put(url, repoData)
    .then(result => dispatch(apiSuccess(DISABLE_REPOSITORY_SUCCESS, result)))
    .catch(result => dispatch(apiError(DISABLE_REPOSITORY_FAILURE, result, { repository })));
};

export const loadEnabledRepos = (extendedParams = {}, silent = false) => (dispatch) => {
  dispatch({ type: ENABLED_REPOSITORIES_REQUEST, params: extendedParams, silent });
  const { searchParams, repoParams } = createEnabledRepoParams(extendedParams);

  return api
    .get('/repositories', {}, repoParams)
    .then(({ data }) => {
      dispatch({
        type: ENABLED_REPOSITORIES_SUCCESS,
        response: normalizeRepositorySets(data),
        search: searchParams,
      });
    })
    .catch((result) => {
      dispatch({
        type: ENABLED_REPOSITORIES_FAILURE,
        result,
      });
    });
};
