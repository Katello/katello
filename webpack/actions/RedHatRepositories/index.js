export const REDHAT_REPOSITORIES_REQUEST = 'REDHAT_REPOSITORIES_REQUEST';
export const REDHAT_REPOSITORIES_SUCCESS = 'REDHAT_REPOSITORIES_SUCCESS';
export const REDHAT_REPOSITORIES_FAILURE = 'REDHAT_REPOSITORIES_FAILURE';

// TODO: replace me with middleware
const CALL_API = function () {};

// Loads a list of Red Hat Repositories
const fetchRedHatRepositories = () => ({
  [CALL_API]: {
    types: [
      REDHAT_REPOSITORIES_REQUEST,
      REDHAT_REPOSITORIES_SUCCESS,
      REDHAT_REPOSITORIES_FAILURE
    ],
    endpoint: '/redhat_repositories'
  }
});

export const loadRedHatRepositories = () => dispatch =>
  dispatch(fetchRedHatRepositories(true));
