import { API_OPERATIONS, post, put } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
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

const rexJobLink = id => ({
  children: __('Go to job details'),
  href: urlBuilder('job_invocations', '', id),
});

export const resolveBulkTraces = ({ traceSearch, bulkParams }) => (dispatch) => {
  const successToast = (response) => {
    // Backend returns an array of job_invocations, typically one for bulk traces
    const jobInvocations = response?.data || [];
    const firstJob = jobInvocations[0];

    if (firstJob?.id) {
      const message = __(`Job '${firstJob.description}' has started.`);
      dispatch(addToast({
        type: 'info',
        message,
        link: rexJobLink(firstJob.id),
        sticky: true,
      }));
    } else {
      dispatch(addToast({
        type: 'success',
        message: __('Trace resolution job has been initiated.'),
      }));
    }
  };

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
