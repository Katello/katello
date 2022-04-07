import { translate as __ } from 'foremanReact/common/I18n';
import { API_OPERATIONS, put } from 'foremanReact/redux/API';
import { errorToast } from '../../../../../scenes/Tasks/helpers';
import { foremanApi } from '../../../../../services/api';
import HOST_CV_AND_ENV_KEY from './HostContentViewConstants';

const updateHostContentViewAndEnvironment = (params, hostId, handleSuccess, handleError) => put({
  type: API_OPERATIONS.PUT,
  key: HOST_CV_AND_ENV_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}`),
  successToast: () => __('Host content view and environment updated'),
  handleSuccess,
  handleError,
  errorToast,
  params,
});

export default updateHostContentViewAndEnvironment;

