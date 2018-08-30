import Immutable from 'seamless-immutable';
import { isEmpty } from 'lodash';

import {
  ENABLED_REPOSITORIES_REQUEST,
  ENABLED_REPOSITORIES_SUCCESS,
  ENABLED_REPOSITORIES_FAILURE,
  REPOSITORY_ENABLED,
  REPOSITORY_DISABLED,
} from '../../consts';

import { initialState } from './enabled.fixtures.js';

const mapRepo = (repo) => {
  const {
    arch,
    id,
    name,
    minor,
  } = repo;

  return ({
    arch,
    id,
    name,
    releasever: minor,
    type: repo.content_type,
    orphaned: repo.product.orphaned,
    contentId: parseInt(repo.content_id, 10),
    productId: parseInt(repo.product.id, 10),
  });
};

const mapRepositories = sets => sets.map(mapRepo);

export default (state = initialState, action) => {
  if (action.type === REPOSITORY_ENABLED) {
    return state.set('repositories', state.repositories.concat([action.repository]));
  } else if (action.type === REPOSITORY_DISABLED) {
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
  } else if (action.type === ENABLED_REPOSITORIES_REQUEST) {
    return state.set(['loading'], true);
  } else if (action.type === ENABLED_REPOSITORIES_SUCCESS) {
    const {
      page, per_page, subtotal, results, // eslint-disable-line camelcase
    } = action.response;

    return Immutable({
      repositories: mapRepositories(results),
      pagination: {
        page: Number(page),
        // server can return per_page: null when there's error in the search query,
        // don't store it in such case
        // eslint-disable-next-line camelcase
        perPage: Number(per_page || state.pagination.perPage),
      },
      itemCount: Number(subtotal),
      loading: false,
      searchIsActive: !isEmpty(action.search),
      search: action.search,
    });
  } else if (action.type === ENABLED_REPOSITORIES_FAILURE) {
    return Immutable({
      repositories: [],
      loading: false,
      error: action.error,
    });
  }
  return state;
};
