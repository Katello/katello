import Immutable from 'seamless-immutable';

import {
  REPOSITORY_SET_REPOSITORIES_REQUEST,
  REPOSITORY_SET_REPOSITORIES_SUCCESS,
  REPOSITORY_SET_REPOSITORIES_FAILURE,
  REPOSITORY_ENABLED,
  REPOSITORY_DISABLED,
} from '../../consts';

import { normalizeContentSetRepositories } from '../../actions/RedHatRepositories/repositorySetRepositories';

const initialState = Immutable({});

export default (state = initialState, action) => {
  let existingRepositorySet;
  let index;

  switch (action.type) {
    case REPOSITORY_SET_REPOSITORIES_REQUEST:
      return state.set(action.contentId, {
        loading: true,
        repositories: [],
        error: null,
      });

    case REPOSITORY_SET_REPOSITORIES_SUCCESS:
      return state.set(action.contentId, {
        loading: false,
        repositories: normalizeContentSetRepositories(
          action.results,
          action.contentId,
          action.productId,
        ),
        error: null,
      });

    case REPOSITORY_SET_REPOSITORIES_FAILURE:
      return state.set(action.contentId, {
        loading: false,
        repositories: [],
        error: action.error,
      });

    case REPOSITORY_ENABLED:
      existingRepositorySet = state[action.repository.contentId];

      if (existingRepositorySet) {
        index = existingRepositorySet.repositories.findIndex(({ arch, releasever }) =>
          arch === action.repository.arch && releasever === action.repository.releasever);

        if (index >= 0) {
          return state.setIn([action.repository.contentId, 'repositories', index, 'enabled'], true);
        }
      }

      return state;

    case REPOSITORY_DISABLED:
      existingRepositorySet = state[action.repository.contentId];

      if (existingRepositorySet) {
        index = existingRepositorySet.repositories.findIndex(repo =>
          repo.arch === action.repository.arch &&
            repo.releasever === action.repository.releasever);

        if (index >= 0) {
          return state.setIn(
            [action.repository.contentId, 'repositories', index, 'enabled'],
            false,
          );
        }
      }

      return state;

    default:
      return state;
  }
};
