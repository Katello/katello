import { API_OPERATIONS } from './HostCollectionsConstants';
import api from '../../services/api';
import { apiError, apiSuccess } from '../../utils/helpers';

const baseApiUrl = '/host_collections';

export const createHostCollection =
  (params, handleSuccess, handleError) => async (dispatch) => {
    try {
      const { data } = await api.post(baseApiUrl, params);
      dispatch(apiSuccess(API_OPERATIONS.CREATE, data));
      if (handleSuccess) handleSuccess(data);
      return data;
    } catch (error) {
      dispatch(apiError(API_OPERATIONS.CREATE, error));
      if (handleError) handleError(error);
      throw error;
    }
  };

export const copyHostCollection =
  (id, newName, handleSuccess, handleError) => async (dispatch) => {
    try {
      const { data } = await api.post(`${baseApiUrl}/${id}/copy`, {
        host_collection: { name: newName },
      });
      dispatch(apiSuccess(API_OPERATIONS.COPY, data));
      if (handleSuccess) handleSuccess(data);
      return data;
    } catch (error) {
      dispatch(apiError(API_OPERATIONS.COPY, error));
      if (handleError) handleError(error);
      throw error;
    }
  };

export const deleteHostCollection =
  (id, handleSuccess, handleError) => async (dispatch) => {
    try {
      const { data } = await api.delete(`${baseApiUrl}/${id}`);
      dispatch(apiSuccess(API_OPERATIONS.DELETE, data));
      if (handleSuccess) handleSuccess(data);
      return data;
    } catch (error) {
      dispatch(apiError(API_OPERATIONS.DELETE, error));
      if (handleError) handleError(error);
      throw error;
    }
  };

export default {
  createHostCollection,
  copyHostCollection,
  deleteHostCollection,
};
