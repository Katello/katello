import api, { orgId } from '../../../services/api';
import { normalizeRepositorySets, repoTypeFilterToSearchQuery, joinSearchQueries } from './helpers';

import {
  REPOSITORY_SETS_REQUEST,
  REPOSITORY_SETS_SUCCESS,
  REPOSITORY_SETS_FAILURE,
} from '../../consts';
import { propsToSnakeCase } from '../../../services/index';

// eslint-disable-next-line import/prefer-default-export
export const loadRepositorySets = (extendedParams = {}) => (dispatch) => {
  dispatch({ type: REPOSITORY_SETS_REQUEST, params: extendedParams });

  const searchParams = extendedParams.search || {};
  const search = joinSearchQueries([
    repoTypeFilterToSearchQuery(searchParams.filters || []),
    searchParams.query,
  ]);

  const params = {
    ...{ organization_id: orgId },
    ...propsToSnakeCase(extendedParams),
    search,
  };

  api
    .get('/repository_sets', {}, params)
    .then(({ data }) => {
      dispatch({
        type: REPOSITORY_SETS_SUCCESS,
        response: normalizeRepositorySets(data),
        search: searchParams,
      });
    })
    .catch((result) => {
      dispatch({
        type: REPOSITORY_SETS_FAILURE,
        result,
      });
    });
};
