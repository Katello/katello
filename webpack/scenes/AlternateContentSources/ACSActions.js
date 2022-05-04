import { API_OPERATIONS, APIActions, get, post } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import api, { orgId } from '../../services/api';
import ACS_KEY, { CREATE_ACS_KEY, DELETE_ACS_KEY } from './ACSConstants';
import { getResponseErrorMsgs } from '../../utils/helpers';

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

export const createACS = params => post({
  type: API_OPERATIONS.POST,
  key: CREATE_ACS_KEY,
  url: api.getApiUrl('/alternate_content_sources'),
  params,
  successToast: response => acsSuccessToast(response),
  errorToast: error => acsErrorToast(error),
});

export const deleteACS = (acsId, handleSuccess) => APIActions.delete({
  type: API_OPERATIONS.DELETE,
  key: DELETE_ACS_KEY,
  url: api.getApiUrl(`/alternate_content_sources/${acsId}`),
  handleSuccess,
  successToast: () => __('Alternate content source deleted'),
  errorToast: error => __(`Something went wrong while deleting this alternate content source! ${getResponseErrorMsgs(error.response)}`),
});

export default getAlternateContentSources;

// acs = Katello::AlternateContentSource.new
// (name:"acs", label:"acs", alternate_content_source_type:"custom", base_url:"abcdef")
