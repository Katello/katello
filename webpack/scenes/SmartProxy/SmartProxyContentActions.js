import { API_OPERATIONS, get, post } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import api, { foremanApi, orgId, foremanTasksApi } from '../../services/api';
import SMART_PROXY_CONTENT_KEY, {
  SMART_PROXY_COUNTS_UPDATE_KEY,
  SMART_PROXY_REPAIR_CONTENT_KEY,
  SMART_PROXY_KEY,
  SMART_PROXY_CONTENT_COUNT_TASK_KEY,
  SMART_PROXY_PENDING_COUNTS_KEY,
  UPDATE_CONTENT_COUNTS_LABEL,
} from './SmartProxyContentConstants';
import { renderTaskStartedToast } from '../Tasks/helpers';
import { getResponseErrorMsgs } from '../../utils/helpers';
import { startPollingTask } from '../Tasks/TaskActions';

const smartProxyContentUrl = ({ smartProxyId, organizationId }) =>
  api.getApiUrl(organizationId ?
    `/capsules/${smartProxyId}/content/sync?organization_id=${organizationId}` :
    `/capsules/${smartProxyId}/content/sync`);

const getSmartProxyContent = ({ smartProxyId, organizationId }) => get({
  type: API_OPERATIONS.GET,
  key: SMART_PROXY_CONTENT_KEY,
  url: smartProxyContentUrl({ smartProxyId, organizationId }),
});

export const pendingContentCountsSearch = () =>
  `label = ${UPDATE_CONTENT_COUNTS_LABEL} and (result = pending or state = running)`;

export const getPendingContentCountTasks = () => get({
  type: API_OPERATIONS.GET,
  key: SMART_PROXY_PENDING_COUNTS_KEY,
  url: `${foremanTasksApi.baseApiPath}/tasks`,
  params: { search: pendingContentCountsSearch(), per_page: 100 },
});

export const getSmartProxies = () => get({
  type: API_OPERATIONS.GET,
  key: SMART_PROXY_KEY,
  url: foremanApi.getApiUrl('/smart_proxies'),
  params: { organization_id: orgId(), per_page: 'all' },
});

export const updateSmartProxyContentCounts = (smartProxyId, params) => (dispatch) => {
  dispatch(post({
    type: API_OPERATIONS.POST,
    key: SMART_PROXY_COUNTS_UPDATE_KEY,
    url: api.getApiUrl(`/capsules/${smartProxyId}/content/update_counts`),
    params,
    handleSuccess: (response) => {
      const task = response?.data;
      renderTaskStartedToast(task, __('Smart proxy content count refresh has started in the background'));
      if (task?.id) {
        dispatch(startPollingTask(SMART_PROXY_CONTENT_COUNT_TASK_KEY, task));
      }
    },
    errorToast: error => __(`Something went wrong while refreshing content counts: ${getResponseErrorMsgs(error?.response)}`),
  }));
};

export const repairSmartProxyContent = (smartProxyId, params) => post({
  type: API_OPERATIONS.POST,
  key: SMART_PROXY_REPAIR_CONTENT_KEY,
  url: api.getApiUrl(`/capsules/${smartProxyId}/content/verify_checksum`),
  params,
  handleSuccess: (response) => {
    renderTaskStartedToast(response?.data, __('Smart proxy verify content checksum has started in the background'));
  },
  errorToast: error => __(`Something went wrong while verifying content checksums: ${getResponseErrorMsgs(error?.response)}`),
});

export default getSmartProxyContent;
