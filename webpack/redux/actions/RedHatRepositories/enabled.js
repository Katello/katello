import api, { orgId } from '../../../services/api';
import {
  normalizeRepositorySets,
  repoTypeFilterToSearchQuery,
  joinSearchQueries,
} from './helpers';
import {
  ENABLED_REPOSITORIES_REQUEST,
  ENABLED_REPOSITORIES_SUCCESS,
  ENABLED_REPOSITORIES_FAILURE,
  REPOSITORY_DISABLED,
} from '../../consts';
import { propsToSnakeCase } from '../../../services/index';
import handleMissingOrg from '../../../common/helpers';

export const setRepositoryDisabled = repository => ({
  type: REPOSITORY_DISABLED,
  repository,
});

export const createEnabledRepoParams = (extendedParams = {}) => {
  const searchParams = extendedParams.search || {};
  const search = joinSearchQueries([
    'redhat = true',
    repoTypeFilterToSearchQuery(searchParams.filters || []),
    searchParams.query,
  ]);

  const repoParams = {
    ...{ organization_id: orgId, enabled: 'true' },
    ...propsToSnakeCase(extendedParams),
    search,
  };

  return { searchParams, repoParams };
};

export const loadEnabledRepos = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: ENABLED_REPOSITORIES_REQUEST, params: extendedParams });
  const { searchParams, repoParams } = createEnabledRepoParams(extendedParams);

  if (handleMissingOrg(repoParams.organization_id, dispatch, ENABLED_REPOSITORIES_FAILURE)) return;

  api
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
