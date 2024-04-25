import { translate as __ } from 'foremanReact/common/I18n';
import { API_OPERATIONS, put } from 'foremanReact/redux/API';
import { errorToast, renderTaskStartedToast } from '../../../../../scenes/Tasks/helpers';
import { foremanApi } from '../../../../../services/api';
import HOST_CV_AND_ENV_KEY from '../../../HostDetails/Cards/ContentViewDetailsCard/HostContentViewConstants';

export const bulkUpdateHostContentViewAndEnvironment =
  (params, bulkParams, handleSuccess, handleError) => put({
    type: API_OPERATIONS.PUT,
    key: HOST_CV_AND_ENV_KEY,
    url: foremanApi.getApiUrl('/hosts/bulk/environment_content_view'),
    ...bulkParams,
    successToast: () => __('Host content view environments updating.'),
    handleSuccess: (response) => {
      if (handleSuccess) handleSuccess(response);
      return renderTaskStartedToast(response.data);
    },
    handleError,
    errorToast,
    params,
  });

export default bulkUpdateHostContentViewAndEnvironment;
