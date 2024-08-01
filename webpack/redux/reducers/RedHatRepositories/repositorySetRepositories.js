import _ from 'lodash';
import Immutable from 'seamless-immutable';

import {
  REPOSITORY_SET_REPOSITORIES_REQUEST,
  REPOSITORY_SET_REPOSITORIES_SUCCESS,
  REPOSITORY_SET_REPOSITORIES_FAILURE,
  ENABLE_REPOSITORY_REQUEST,
  ENABLE_REPOSITORY_FAILURE,
  REPOSITORY_ENABLED,
  REPOSITORY_DISABLED,
} from '../../consts';

import { normalizeContentSetRepositories } from '../../actions/RedHatRepositories/repositorySetRepositories';

const normalizeArch = (arch) => {
  if (arch === 'noarch') {
    return undefined;
  }
  return arch;
};

const substitutionMatches = (value1, value2) => {
  if (_.isEmpty(value1) && _.isEmpty(value2)) {
    return true;
  }
  return value1 === value2;
};

const reposMatch = (repoA, repoB) => (
  substitutionMatches(normalizeArch(repoA.arch), normalizeArch(repoB.arch)) &&
    substitutionMatches(repoA.releasever, repoB.releasever)
);

const changeRepoState = (state, repoToChange, stateDiff) => {
  const existingRepositorySet = state[repoToChange.contentId];

  if (existingRepositorySet) {
    const index = existingRepositorySet
      .repositories
      .findIndex(repo => reposMatch(repo, repoToChange));

    if (index >= 0) {
      const repo = existingRepositorySet.repositories[index];
      return state.setIn([repoToChange.contentId, 'repositories', index], {
        ...repo,
        ...stateDiff,
      });
    }
  }

  return state;
};

const initialState = Immutable({});

export default (state = initialState, action) => {
  switch (action.type) {
  case ENABLE_REPOSITORY_REQUEST:
    return changeRepoState(state, action.repository, { loading: true });

  case ENABLE_REPOSITORY_FAILURE:
    return changeRepoState(state, action.payload.repository, { loading: false, error: true });

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
    return state.set(action.payload.contentId, {
      loading: false,
      repositories: [],
      error: action.error,
    });

  case REPOSITORY_ENABLED:
    return changeRepoState(state, action.repository, {
      enabled: true,
      loading: false,
      error: false,
    });

  case REPOSITORY_DISABLED:
    return changeRepoState(state, action.repository, { enabled: false });

  default:
    return state;
  }
};
