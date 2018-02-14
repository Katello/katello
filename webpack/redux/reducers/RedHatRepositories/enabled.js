import Immutable from 'seamless-immutable';

import {
  ENABLED_REPOSITORIES_REQUEST,
  ENABLED_REPOSITORIES_SUCCESS,
  ENABLED_REPOSITORIES_FAILURE,
  REPOSITORY_ENABLED,
  REPOSITORY_DISABLED,
} from '../../consts';

import { initialState } from './enabled.fixtures.js';

const flattenRepositorySets = sets =>
  sets
    .map(({
      id: contentId, type, product: { id: productId }, repositories,
    }) =>
      repositories.map(repo => ({
        type,
        contentId,
        productId,
        ...repo,
      })))
    .reduce((a, b) => a.concat(b), []);

export default (state = initialState, action) => {
  if (action.type === REPOSITORY_ENABLED) {
    return state.set('repositories', state.repositories.concat([action.repository]));
  }

  if (action.type === REPOSITORY_DISABLED) {
    return state.set(
      'repositories',
      state.repositories.filter((repo) => {
        const isMatch =
          action.repository.arch === repo.arch &&
          action.repository.contentId === repo.contentId &&
          action.repository.productId === repo.productId &&
          action.repository.releasever === repo.releasever;

        return !isMatch;
      }),
    );
  }

  if (action.type === ENABLED_REPOSITORIES_REQUEST) {
    return state.set(['loading'], true);
  }

  if (action.type === ENABLED_REPOSITORIES_SUCCESS) {
    const {
      page, per_page: perPage, subtotal, total, results,
    } = action.response;

    return Immutable({
      repositories: flattenRepositorySets(results),
      loading: false,
      searchIsActive: !!action.search,
      page,
      perPage,
      subtotal,
      total,
    });
  }

  if (action.type === ENABLED_REPOSITORIES_FAILURE) {
    return Immutable({
      repositories: [],
      loading: false,
      error: action.error,
    });
  }

  return state;
};
