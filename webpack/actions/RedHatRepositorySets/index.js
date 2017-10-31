export const REDHAT_REPOSITORY_SETS_REQUEST = 'REDHAT_REPOSITORY_SETS_REQUEST';
export const REDHAT_REPOSITORY_SETS_SUCCESS = 'REDHAT_REPOSITORY_SETS_SUCCESS';
export const REDHAT_REPOSITORY_SETS_FAILURE = 'REDHAT_REPOSITORY_SETS_FAILURE';

// TODO: replace me with middleware
const CALL_API = function () {};

// Loads a list of Red Hat Repository sets
const fetchRedHatRepositorySets = () => ({
  [CALL_API]: {
    types: [
      REDHAT_REPOSITORY_SETS_REQUEST,
      REDHAT_REPOSITORY_SETS_SUCCESS,
      REDHAT_REPOSITORY_SETS_FAILURE
    ],
    endpoint: '/redhat_repository_sets'
  }
});

export const loadRedHatRepositorySets = () => dispatch =>
  dispatch(fetchRedHatRepositorySets(false));
