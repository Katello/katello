import { foremanApi, userId } from '../../../services/api';

import {
  TABLES_REQUEST,
  TABLES_SUCCESS,
  TABLES_FAILURE,
  CREATE_TABLE,
  CREATE_TABLE_SUCCESS,
  CREATE_TABLE_FAILURE,
  UPDATE_TABLE,
  UPDATE_TABLE_SUCCESS,
  UPDATE_TABLE_FAILURE,
} from './TableConstants';

const getResponseError = ({ data }) => data && (data.displayMessage || data.error);

export const loadTables = () => async (dispatch) => {
  dispatch({ type: TABLES_REQUEST, params: {} });

  try {
    const { data } = await foremanApi.get(`/users/${userId()}/table_preferences`, {});
    return dispatch({
      type: TABLES_SUCCESS,
      payload: data,
    });
  } catch (error) {
    const { response } = error;
    return dispatch({
      type: TABLES_FAILURE,
      error: getResponseError(response),
    });
  }
};

export const createColumns = (params = {}) => async (dispatch) => {
  dispatch({ type: CREATE_TABLE, params });

  try {
    const { data } = await foremanApi.post(`/users/${userId()}/table_preferences`, params);
    return dispatch({
      type: CREATE_TABLE_SUCCESS,
      payload: [data],
    });
  } catch (error) {
    const { response } = error;
    return dispatch({
      type: CREATE_TABLE_FAILURE,
      error: getResponseError(response),
    });
  }
};

export const updateColumns = (params = {}) => async (dispatch) => {
  dispatch({ type: UPDATE_TABLE, params });
  const updateParams = { columns: params.columns };

  try {
    const { data } = await foremanApi
      .put(`/users/${userId()}/table_preferences/${params.name}`, updateParams);
    return dispatch({
      type: UPDATE_TABLE_SUCCESS,
      payload: [data],
    });
  } catch (error) {
    const { response } = error;
    return dispatch({
      type: UPDATE_TABLE_FAILURE,
      error: getResponseError(response),
    });
  }
};
export default loadTables;
