import { translate as __ } from 'foremanReact/common/I18n';
import { API_OPERATIONS, put } from 'foremanReact/redux/API';
import { errorToast, renderTaskStartedToast } from '../../../../../scenes/Tasks/helpers';
import { foremanApi } from '../../../../../services/api';

const BULK_HOST_CONTENT_OVERRIDES_KEY = 'BULK_HOST_CONTENT_OVERRIDES';

export const bulkUpdateHostContentOverrides =
  (params, handleSuccess, handleError) => put({
    type: API_OPERATIONS.PUT,
    key: BULK_HOST_CONTENT_OVERRIDES_KEY,
    url: foremanApi.getApiUrl('/hosts/bulk/content_overrides'),
    successToast: () => __('Content overrides updating.'),
    handleSuccess: (response) => {
      if (handleSuccess) handleSuccess(response);
      return renderTaskStartedToast(response.data);
    },
    handleError,
    errorToast,
    params,
  });

export default bulkUpdateHostContentOverrides;
