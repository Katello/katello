import { translate as __ } from 'foremanReact/common/I18n';
import { API_OPERATIONS, post } from 'foremanReact/redux/API';
import api, { orgId } from '../../services/api';
import { CREATE_FLATPAK_REMOTES_KEY }
  from './FlatpakRemotesConstants';
import { getResponseErrorMsgs } from '../../utils/helpers';

export const createParamsWithOrg = (params) => {
  const getParams = {
    organization_id: orgId(),
    ...params,
  };
  return getParams;
};
const cvSuccessToast = (response) => {
  const { data: { name } } = response;
  return __(`Flatpak Remote ${name} created`);
};

export const cvErrorToast = (error) => {
  const message = getResponseErrorMsgs(error.response);
  return message;
};
export const createFlatpakRemote = params => post({
  type: API_OPERATIONS.POST,
  key: CREATE_FLATPAK_REMOTES_KEY,
  url: api.getApiUrl('/flatpak_remotes'),
  params: createParamsWithOrg(params),
  successToast: response => cvSuccessToast(response),
  errorToast: error => cvErrorToast(error),
});
