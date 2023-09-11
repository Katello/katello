import Immutable from 'seamless-immutable';
import { isEmpty } from 'lodash';


import {
  ENABLED_REPOSITORIES_REQUEST,
  ENABLED_REPOSITORIES_SUCCESS,
  ENABLED_REPOSITORIES_FAILURE,
  DISABLE_REPOSITORY_REQUEST,
  DISABLE_REPOSITORY_FAILURE,
} from '../../consts';

import { initialState } from './enabled.fixtures.js';

const mapRepo = (repo) => {
  const {
    arch,
    id,
    name,
    minor,
    content_label: label,
  } = repo;

  return ({
    arch,
    id,
    name,
    label,
    releasever: minor,
    type: repo.content_type,
    orphaned: repo.product.orphaned,
    contentId: parseInt(repo.content_id, 10),
    productId: parseInt(repo.product.id, 10),
    canDisable: repo.content_view_versions.length === 0,
  });
};

const mapRepositories = sets => sets.map(mapRepo);

const reposMatch = (repoA, repoB) => (
  repoA.arch === repoB.arch &&
  repoA.contentId === repoB.contentId &&
  repoA.productId === repoB.productId &&
  repoA.releasever === repoB.releasever
);

const changeRepoState = (state, repoToChange, stateDiff) => (
  state.set(
    'repositories',
    state.repositories.map((repo) => {
      if (reposMatch(repo, repoToChange)) {
        return {
          ...repo,
          ...stateDiff,
        };
      }
      return repo;
    }),
  )
);

export default (state = initialState, action) => {
  switch (action.type) {
  case DISABLE_REPOSITORY_REQUEST:
    return changeRepoState(state, action.repository, { loading: true });
  case DISABLE_REPOSITORY_FAILURE:
    return changeRepoState(state, action.payload.repository, { loading: false });
  case ENABLED_REPOSITORIES_REQUEST:
    if (!action.silent) {
      return state.set(['loading'], true);
    }
    return state;
  case ENABLED_REPOSITORIES_SUCCESS: {
    const {
      page,
      per_page, // eslint-disable-line camelcase
      subtotal,
      results,
    } = action.response;
    return Immutable({
      repositories: mapRepositories(results),
      pagination: {
        page: Number(page) || 1,
        // server can return per_page: null when there's error in the search query,
        // don't store it in such case
        // eslint-disable-next-line camelcase
        perPage: (per_page || state.pagination.perPage)
        // eslint-disable-next-line camelcase
            && Number(per_page || state.pagination.perPage),
      },
      itemCount: Number(subtotal),
      loading: false,
      searchIsActive: !isEmpty(action.search),
      search: action.search,
    });
  }
  case ENABLED_REPOSITORIES_FAILURE: {
    const { error, missingPermissions } = action;
    return Immutable({
      repositories: [],
      loading: false,
      error,
      missingPermissions,
    });
  }
  default:
    return state;
  }
};
