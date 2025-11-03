import { translate as __ } from 'foremanReact/common/I18n';
import { API_OPERATIONS, put } from 'foremanReact/redux/API';
import { errorToast, renderTaskStartedToast } from '../../../../../scenes/Tasks/helpers';
import { foremanApi } from '../../../../../services/api';

export const BULK_SYSTEM_PURPOSE_KEY = 'BULK_SYSTEM_PURPOSE';

export const bulkUpdateHostSystemPurpose =
  (params, handleSuccess, handleError) => put({
    type: API_OPERATIONS.PUT,
    key: BULK_SYSTEM_PURPOSE_KEY,
    url: foremanApi.getApiUrl('/hosts/bulk/system_purpose'),
    successToast: () => __('Host system purpose updating.'),
    handleSuccess: (response) => {
      if (handleSuccess) handleSuccess(response);
      return renderTaskStartedToast(response.data);
    },
    handleError,
    errorToast,
    params,
  });

export const bulkUpdateHostReleaseVersion =
  (params, handleSuccess, handleError) => put({
    type: API_OPERATIONS.PUT,
    key: BULK_SYSTEM_PURPOSE_KEY,
    url: foremanApi.getApiUrl('/hosts/bulk/release_version'),
    successToast: () => __('Host release version updating.'),
    handleSuccess: (response) => {
      if (handleSuccess) handleSuccess(response);
      return renderTaskStartedToast(response.data);
    },
    handleError,
    errorToast,
    params,
  });
