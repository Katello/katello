import { API_OPERATIONS, get, put } from 'foremanReact/redux/API';
import { renderTaskStartedToast } from '../../../../scenes/Tasks/helpers';
import { foremanApi } from '../../../../services/api';
import { getResponseErrorMsgs } from '../../../../utils/helpers';
import { HOST_PACKAGES_INSTALL_KEY, HOST_PACKAGES_KEY } from './HostPackagesConstants';

const errorToast = (error) => {
  const message = getResponseErrorMsgs(error.response);
  return message;
};

export const getInstalledPackagesWithLatest = (hostId, params) => get({
  type: API_OPERATIONS.GET,
  key: HOST_PACKAGES_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/packages?include_latest_upgradable=true`),
  params,
});
export default getInstalledPackagesWithLatest;

export const installPackageViaKatelloAgent = (hostId, params) => put({
  type: API_OPERATIONS.PUT,
  key: HOST_PACKAGES_INSTALL_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/packages/install`),
  handleSuccess: ({ data }) => renderTaskStartedToast(data),
  errorToast: error => errorToast(error),
  params,
});
