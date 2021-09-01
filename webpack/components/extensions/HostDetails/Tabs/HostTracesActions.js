import { API_OPERATIONS, get, put } from 'foremanReact/redux/API';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { addToast } from 'foremanReact/redux/actions/toasts';
import { HOST_TRACES_KEY, RESOLVE_HOST_TRACES_TASK_KEY } from './HostTracesConstants';
import { foremanApi } from '../../../../services/api';
import { getResponseErrorMsgs, pluralize } from '../../../../utils/helpers';

const errorToast = (error) => {
  const message = getResponseErrorMsgs(error.response);
  return message;
};

export const getHostTraces = (hostId, params) => get({
  type: API_OPERATIONS.GET,
  key: HOST_TRACES_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/traces`),
  params,
});

export const resolveHostTraces = (hostId, params, dispatch) => {
  const { traceIds } = propsToCamelCase(params);
  return put({
    type: API_OPERATIONS.PUT,
    key: RESOLVE_HOST_TRACES_TASK_KEY,
    url: foremanApi.getApiUrl(`/hosts/${hostId}/traces/resolve`),
    handleSuccess: (response) => {
      const { data: { id } } = response;
      const traceCount = Number(traceIds.length);
      dispatch({
        type: 'TOASTS_ADD',
        payload: {
          key: id,
          message: {
            type: 'success',
            message: `Restarting ${pluralize(traceCount, 'trace')}.`,
            link: {
              children: 'View task',
              href: `/foreman_tasks/tasks/${id}`,
            },
          },
        },
      });
    },
    // errorToast: error => errorToast(error),
    params,
  });
};
