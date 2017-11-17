import { get } from '../../services/api';

export const REDHAT_REPOSITORIES_REQUEST = 'REDHAT_REPOSITORIES_REQUEST';
export const REDHAT_REPOSITORIES_SUCCESS = 'REDHAT_REPOSITORIES_SUCCESS';
export const REDHAT_REPOSITORIES_FAILURE = 'REDHAT_REPOSITORIES_FAILURE';

export const loadRedHatRepositories = () => (dispatch) => {
  get({ name: 'PRODUCT_REPOSITORY_SETS' })
    .then((response) => {
      dispatch({
        type: REDHAT_REPOSITORIES_SUCCESS,
        response,
      });
    })
    .catch((result) => {
      dispatch({
        type: REDHAT_REPOSITORIES_FAILURE,
        result,
      });
    });
};
