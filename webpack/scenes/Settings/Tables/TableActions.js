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

export const loadTables = () => (dispatch) => {
  dispatch({ type: TABLES_REQUEST, params: {} });

  return foremanApi
    .get(`/users/${userId()}/table_preferences`, {})
    .then(({ data }) => {
      dispatch({
        type: TABLES_SUCCESS,
        payload: data,
      });
    })
    .catch((result) => {
      const { response } = result;
      dispatch({
        type: TABLES_FAILURE,
        error: getResponseError(response),
      });
    });
};

export const createColumns = (params = {}) => (dispatch) => {
  dispatch({ type: CREATE_TABLE, params });

  return foremanApi
    .post(`/users/${userId()}/table_preferences`, params)
    .then(({ data }) => {
      dispatch({
        type: CREATE_TABLE_SUCCESS,
        payload: [data],
      });
    })
    .catch((result) => {
      dispatch({
        type: CREATE_TABLE_FAILURE,
        error: getResponseError(result.response),
      });
    });
};
export const updateColumns = (params = {}) => (dispatch) => {
  dispatch({ type: UPDATE_TABLE, params });
  const updateParams = { columns: params.columns };
  return foremanApi
    .put(`/users/${userId()}/table_preferences/${params.name}`, updateParams)
    .then(({ data }) => {
      dispatch({
        type: UPDATE_TABLE_SUCCESS,
        payload: [data],
      });
    })
    .catch((result) => {
      dispatch({
        type: UPDATE_TABLE_FAILURE,
        error: getResponseError(result.response),
      });
    });
};
export default loadTables;
