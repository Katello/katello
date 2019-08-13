import { foremanApi, foremanEndpoint } from '../../services/api';
import {
  GET_ORGANIZATIONS_LIST_SUCCESS,
  GET_ORGANIZATIONS_LIST_FAILURE,
  CHANGE_CURRENT_ORGANIZATION_SUCCESS,
  CHANGE_CURRENT_ORGANIZATION_FAILURE,
  GET_ORGANIZATIONS_LIST_REQUEST,
} from '../../redux/consts';

export const getOrganiztionsList = () => async (dispatch) => {
  dispatch({ type: GET_ORGANIZATIONS_LIST_REQUEST });
  try {
    const { data } = await foremanApi.get('/organizations');
    return dispatch({
      type: GET_ORGANIZATIONS_LIST_SUCCESS,
      payload: data,
    });
  } catch (error) {
    return dispatch({
      type: GET_ORGANIZATIONS_LIST_FAILURE,
      payload: error,
    });
  }
};

export const changeCurrentOrganization = orgID => async (dispatch) => {
  try {
    await foremanEndpoint.get(`organizations/${orgID}/select`);
    return dispatch({
      type: CHANGE_CURRENT_ORGANIZATION_SUCCESS,
      payload: orgID,
    });
  } catch (e) {
    return dispatch({
      type: CHANGE_CURRENT_ORGANIZATION_FAILURE,
      payload: orgID,
    });
  }
};
