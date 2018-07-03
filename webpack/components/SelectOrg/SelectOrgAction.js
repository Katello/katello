import { foremanApi, foremanEndpoint } from '../../services/api';
import {
  GET_ORGANIZATIONS_LIST_SUCCESS,
  GET_ORGANIZATIONS_LIST_FAILURE,
  CHANGE_CURRENT_ORGANIZATION_SUCCESS,
  CHANGE_CURRENT_ORGANIZATION_FAILURE,
  GET_ORGANIZATIONS_LIST_REQUEST,
} from '../../redux/consts';

export const getOrganiztionsList = () => (dispatch) => {
  dispatch({ type: GET_ORGANIZATIONS_LIST_REQUEST });
  foremanApi
    .get('/organizations')
    .then(({ data }) => {
      dispatch({
        type: GET_ORGANIZATIONS_LIST_SUCCESS,
        payload: data,
      });
    })
    .catch((result) => {
      dispatch({
        type: GET_ORGANIZATIONS_LIST_FAILURE,
        payload: result,
      });
    });
};

export const changeCurrentOrgaziation = orgID => dispatch => foremanEndpoint
  .get(`organizations/${orgID}/select`)
  .then(() => {
    dispatch({
      type: CHANGE_CURRENT_ORGANIZATION_SUCCESS,
      payload: orgID,
    });
  })
  .catch(() => {
    dispatch({
      type: CHANGE_CURRENT_ORGANIZATION_FAILURE,
      payload: orgID,
    });
  });
