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
  switch (action.type) {
    case REPOSITORY_ENABLED:
      return state.set('repositories', state.repositories.concat([action.repository]));

    case REPOSITORY_DISABLED:
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

    case ENABLED_REPOSITORIES_REQUEST:
      return state.set(['loading'], true);

    case ENABLED_REPOSITORIES_SUCCESS:
      return Immutable({
        repositories: flattenRepositorySets(action.response.results),
        loading: false,
        searchIsActive: !!action.search,
      });

    case ENABLED_REPOSITORIES_FAILURE:
      return Immutable({
        repositories: [],
        loading: false,
        error: action.error,
      });

    default:
      return state;
  }
};
