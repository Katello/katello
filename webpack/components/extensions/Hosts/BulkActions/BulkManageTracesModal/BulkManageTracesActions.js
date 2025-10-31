import { API_OPERATIONS, post, put } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import { addToast } from 'foremanReact/components/ToastsList/slice';
import { foremanApi } from '../../../../../services/api';
import { BULK_TRACES_KEY } from './BulkManageTracesConstants';

export const getBulkHostTraces = (orgId, hostSearch, params = {}) => post({
  type: API_OPERATIONS.POST,
  key: BULK_TRACES_KEY,
  url: foremanApi.getApiUrl('/hosts/bulk/traces'),
  params: {
    organization_id: orgId,
    included: {
      search: hostSearch,
    },
    ...params,
  },
});

export const resolveBulkTraces = ({ traceSearch, bulkParams }) => (dispatch) => {
  const successToast = () => dispatch(addToast({
    type: 'success',
    message: __('Trace resolution job has been initiated.'),
  }));

  const errorToast = error => dispatch(addToast({
    type: 'error',
    message: error?.message || __('Failed to initiate trace resolution job.'),
  }));

  return dispatch(put({
    type: API_OPERATIONS.PUT,
    key: `${BULK_TRACES_KEY}_RESOLVE`,
    url: foremanApi.getApiUrl('/hosts/bulk/resolve_traces'),
    params: {
      trace_search: traceSearch,
      ...bulkParams,
    },
    handleSuccess: successToast,
    handleError: errorToast,
  }));
};
