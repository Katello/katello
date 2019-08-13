import { propsToSnakeCase } from 'foremanReact/common/helpers';

import api, { orgId } from '../../../services/api';
import {
  normalizeRepositorySets,
  repoTypeFilterToSearchQuery,
  productsIdsToSearchQuery,
  joinSearchQueries,
  recommendedRepositorySetsQuery,
} from './helpers';

import {
  REPOSITORY_SETS_REQUEST,
  REPOSITORY_SETS_SUCCESS,
  REPOSITORY_SETS_FAILURE,
  REPOSITORY_SETS_UPDATE_RECOMMENDED,
} from '../../consts';

// eslint-disable-next-line import/prefer-default-export
export const loadRepositorySets = (extendedParams = {}) => async (dispatch, getState) => {
  dispatch({ type: REPOSITORY_SETS_REQUEST, params: extendedParams });
  // Assemble params
  const { recommended } = getState().katello.redHatRepositories.sets;
  const searchParams = extendedParams.search || {};
  const search = joinSearchQueries([
    repoTypeFilterToSearchQuery(searchParams.filters || []),
    productsIdsToSearchQuery(searchParams.products || []),
    searchParams.query,
    recommended ? recommendedRepositorySetsQuery : '',
  ]);
  const params = {
    ...{ organization_id: orgId(), with_active_subscription: true },
    ...propsToSnakeCase(extendedParams),
    search,
  };

  try {
    const { data } = await api.get('/repository_sets', {}, params);
    return dispatch({
      type: REPOSITORY_SETS_SUCCESS,
      payload: {
        response: normalizeRepositorySets(data),
        search: searchParams,
      },
    });
  } catch (error) {
    return dispatch({
      type: REPOSITORY_SETS_FAILURE,
      payload: error,
    });
  }
};

export const updateRecommendedRepositorySets = value => (dispatch, getState) => {
  const { search } = getState().katello.redHatRepositories.sets;

  dispatch({
    type: REPOSITORY_SETS_UPDATE_RECOMMENDED,
    payload: value,
  });

  dispatch(loadRepositorySets({ search }));
};
