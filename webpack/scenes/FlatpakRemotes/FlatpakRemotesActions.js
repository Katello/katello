import { translate as __ } from 'foremanReact/common/I18n';
import { API_OPERATIONS, get, post } from 'foremanReact/redux/API';
import api, { orgId } from '../../services/api';
import {
  CREATE_FLATPAK_REMOTES_KEY}
 from './FlatpakRemotesConstants';
import { getResponseErrorMsgs } from '../../utils/helpers';
import { renderTaskStartedToast } from '../Tasks/helpers';

export const createFlatpakRemote = params => post({
  type: API_OPERATIONS.POST,
  key: CREATE_FLATPAK_REMOTES_KEY,
  url: api.getApiUrl('/flatpak_remotes'),
  params:createParamsWithOrg(params),
  successToast: response => "Success!",
  errorToast: error => "Failure",
});

export const createParamsWithOrg = params => {
    const getParams ={
        organization_id: orgId(),
        ...params
    }
    return getParams;
}