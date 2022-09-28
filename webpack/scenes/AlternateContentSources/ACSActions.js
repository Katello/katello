import { API_OPERATIONS, APIActions, get, post } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import api, { orgId } from '../../services/api';
import ACS_KEY, {
  acsDetailsKey,
  acsRefreshKey,
  CREATE_ACS_KEY,
  DELETE_ACS_KEY,
  EDIT_ACS_KEY,
  PRODUCTS_KEY,
} from './ACSConstants';
import { getResponseErrorMsgs } from '../../utils/helpers';
import { renderTaskStartedToast } from '../Tasks/helpers';

const acsSuccessToast = (response) => {
  const { data: { name } } = response;
  return __(`Alternate content source ${name} created`);
};

export const acsErrorToast = (error) => {
  const message = getResponseErrorMsgs(error.response);
  return message;
};

export const createACSParams = (extraParams) => {
  const getParams = {
    organization_id: orgId(),
    ...extraParams,
  };
  return getParams;
};

const getAlternateContentSources = (extraParams, id = '') => get({
  type: API_OPERATIONS.GET,
  key: ACS_KEY + id,
  url: api.getApiUrl('/alternate_content_sources'),
  params: createACSParams(extraParams),
});

export const getACSDetails = (acsId, extraParams = {}) => get({
  type: API_OPERATIONS.GET,
  key: acsDetailsKey(acsId),
  params: { organization_id: orgId(), include_permissions: true, ...extraParams },
  url: api.getApiUrl(`/alternate_content_sources/${acsId}`),
  errorToast: error => acsErrorToast(error),
});

export const createACS = (params, name, handleSuccess) => post({
  type: API_OPERATIONS.POST,
  key: CREATE_ACS_KEY + name,
  url: api.getApiUrl('/alternate_content_sources'),
  params,
  handleSuccess,
  successToast: response => acsSuccessToast(response),
  errorToast: error => acsErrorToast(error),
});

export const deleteACS = (acsId, handleSuccess) => APIActions.delete({
  type: API_OPERATIONS.DELETE,
  key: DELETE_ACS_KEY,
  url: api.getApiUrl(`/alternate_content_sources/${acsId}`),
  handleSuccess,
  successToast: () => __('Alternate content source deleted'),
  errorToast: error => acsErrorToast(error),
});

export const refreshACS = (acsId, handleSuccess) => post({
  type: API_OPERATIONS.POST,
  key: acsRefreshKey(acsId),
  url: api.getApiUrl(`/alternate_content_sources/${acsId}/refresh`),
  params: { id: acsId },
  handleSuccess: (response) => {
    if (handleSuccess) {
      handleSuccess();
    }
    return renderTaskStartedToast(response.data);
  },
  errorToast: error => acsErrorToast(error),
});

export const getProducts = () => get({
  type: API_OPERATIONS.GET,
  key: PRODUCTS_KEY,
  url: api.getApiUrl('/products'),
  params: {
    organization_id: orgId(), full_result: true, enabled: true, non_empty: true,
  },
});

export const editACS = (acsId, params, handleSuccess, handleError) => APIActions.put({
  type: API_OPERATIONS.PUT,
  key: EDIT_ACS_KEY,
  url: api.getApiUrl(`/alternate_content_sources/${acsId}`),
  params,
  handleSuccess,
  handleError,
  successToast: () => __('Alternate content source edited'),
  errorToast: error => acsErrorToast(error),
});

export default getAlternateContentSources;

