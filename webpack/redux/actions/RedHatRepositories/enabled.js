import { propsToSnakeCase } from 'foremanReact/common/helpers';
import { get } from 'lodash';
import api, { orgId } from '../../../services/api';
import {
  normalizeRepositorySets,
  repoTypeFilterToSearchQuery,
  productsIdsToSearchQuery,
  joinSearchQueries,
} from './helpers';
import { apiError, apiSuccess } from '../../../utils/helpers.js';

import {
  ENABLED_REPOSITORIES_REQUEST,
  ENABLED_REPOSITORIES_SUCCESS,
  ENABLED_REPOSITORIES_FAILURE,
  DISABLE_REPOSITORY_REQUEST,
  DISABLE_REPOSITORY_SUCCESS,
  DISABLE_REPOSITORY_FAILURE,
  REPOSITORY_DISABLED,
} from '../../consts';

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
    ...{ organization_id: orgId(), enabled: 'true', include_permissions: 'true' },
    ...propsToSnakeCase(extendedParams),
    search,
  };

  return { searchParams, repoParams };
};

export const disableRepository = repository => async (dispatch) => {
  const {
    productId, contentId, arch, releasever, id,
  } = repository;

  const repoData = {
    id: contentId,
    product_id: productId,
    basearch: arch,
    releasever,
    repository_id: id,
  };
  dispatch({ type: DISABLE_REPOSITORY_REQUEST, repository });
  const url = `/products/${productId}/repository_sets/${contentId}/disable`;
  try {
    const result = await api.put(url, repoData);
    return dispatch(apiSuccess(DISABLE_REPOSITORY_SUCCESS, result));
  } catch (error) {
    return dispatch(apiError(DISABLE_REPOSITORY_FAILURE, error, { repository }));
  }
};

export const loadEnabledRepos = (extendedParams = {}, silent = false) => async (dispatch) => {
  dispatch({ type: ENABLED_REPOSITORIES_REQUEST, params: extendedParams, silent });
  const { searchParams, repoParams } = createEnabledRepoParams(extendedParams);

  try {
    const { data } = await api.get('/repositories', {}, repoParams);
    return dispatch({
      type: ENABLED_REPOSITORIES_SUCCESS,
      response: normalizeRepositorySets(data),
      search: searchParams,
    });
  } catch (error) {
    const missingPermissions = get(error, ['response', 'data', 'error', 'missing_permissions']);
    return dispatch({
      type: ENABLED_REPOSITORIES_FAILURE,
      result: error,
      missingPermissions,
    });
  }
};
