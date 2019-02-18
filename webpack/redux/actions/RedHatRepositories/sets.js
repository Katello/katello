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
export const loadRepositorySets = (extendedParams = {}) => (dispatch, getState) => {
  const { recommended } = getState().katello.redHatRepositories.sets;

  dispatch({ type: REPOSITORY_SETS_REQUEST, params: extendedParams });

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

  api
    .get('/repository_sets', {}, params)
    .then(({ data }) => {
      dispatch({
        type: REPOSITORY_SETS_SUCCESS,
        payload: {
          response: normalizeRepositorySets(data),
          search: searchParams,
        },
      });
    })
    .catch((result) => {
      dispatch({
        type: REPOSITORY_SETS_FAILURE,
        payload: result,
      });
    });
};

export const updateRecommendedRepositorySets = value => (dispatch, getState) => {
  const { search } = getState().katello.redHatRepositories.sets;

  dispatch({
    type: REPOSITORY_SETS_UPDATE_RECOMMENDED,
    payload: value,
  });

  dispatch(loadRepositorySets({ search }));
};
