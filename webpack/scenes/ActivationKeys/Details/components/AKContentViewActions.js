import { translate as __ } from 'foremanReact/common/I18n';
import { API_OPERATIONS, put } from 'foremanReact/redux/API';
import { errorToast } from '../../../../scenes/Tasks/helpers';
import katelloApi from '../../../../services/api';
import AK_CV_AND_ENV_KEY from './AKContentViewConstants';

const assignAKCVEnvironments = (
  params,
  akId,
  handleSuccess,
  handleError,
) => put({
  type: API_OPERATIONS.PUT,
  key: AK_CV_AND_ENV_KEY,
  url: katelloApi.getApiUrl(`/activation_keys/${akId}`),
  successToast: () => __('Activation key content view environments updated'),
  handleSuccess,
  handleError,
  errorToast,
  params,
});

export default assignAKCVEnvironments;
