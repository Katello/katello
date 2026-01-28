import { API_OPERATIONS, put } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import store from 'foremanReact/redux';
import { addToast } from 'foremanReact/components/ToastsList/slice';
import { errorToast } from '../../../../../scenes/Tasks/helpers';
import { foremanApi } from '../../../../../services/api';

const BULK_ASSIGN_CVES_KEY = 'BULK_ASSIGN_CONTENT_VIEW_ENVIRONMENTS';

const successToast = (response) => {
  const { displayMessage, warningMessage } = response.data || {};
  const successMessage = displayMessage || __('Host content view environments updated.');

  // Success toast
  store.dispatch(addToast({
    type: 'success',
    message: successMessage,
  }));

  // Separate warning toast if hosts were skipped
  if (warningMessage) {
    store.dispatch(addToast({
      type: 'warning',
      message: warningMessage,
    }));
  }
};

export const bulkAssignContentViewEnvironments = (
  params,
  handleSuccess,
  handleError,
) =>
  put({
    type: API_OPERATIONS.PUT,
    key: BULK_ASSIGN_CVES_KEY,
    url: foremanApi.getApiUrl('/hosts/bulk/assign_content_view_environments'),
    params,
    handleSuccess: (response) => {
      successToast(response);
      if (handleSuccess) handleSuccess(response);
    },
    handleError,
    errorToast,
  });

export default bulkAssignContentViewEnvironments;
