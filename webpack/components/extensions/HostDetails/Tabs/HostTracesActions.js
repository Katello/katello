import { API_OPERATIONS, get, put } from 'foremanReact/redux/API';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { HOST_TRACES_KEY } from './HostTracesConstants';
import { foremanApi } from '../../../../services/api';
import { getResponseErrorMsgs } from '../../../../utils/helpers';

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

const filteredTraces = (prevResponse, traceIds) => {
  const newResults = [...prevResponse.results].filter(result => !traceIds.includes(result?.id));
  return {
    ...prevResponse,
    results: newResults,
  };
};

export const resolveHostTraces = (hostId, params) => {
  const { traceIds } = propsToCamelCase(params);
  return put({
    type: API_OPERATIONS.PUT,
    key: HOST_TRACES_KEY,
    url: foremanApi.getApiUrl(`/hosts/${hostId}/traces/resolve`),
    successToast: () => `Restarting ${traceIds.length} traces.`,
    errorToast: error => errorToast(error),
    updateData: (prevResponse, newResponse) => {
      console.log({prevResponse, newResponse})
      console.log(filteredTraces(prevResponse, traceIds))
      if (newResponse.label && newResponse.start_at) {
        // then it's a task and not a result list
        return filteredTraces(prevResponse, traceIds);
      }
      return newResponse;
    },
    params,
  });
};
