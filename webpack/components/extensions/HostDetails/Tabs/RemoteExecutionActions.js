import { API_OPERATIONS, post } from 'foremanReact/redux/API';
import { REX_JOB_INVOCATIONS_KEY, REX_FEATURES } from './RemoteExecutionConstants';
import { foremanApi } from '../../../../services/api';
import { getResponseErrorMsgs } from '../../../../utils/helpers';
import { renderTaskStartedToast } from '../../../../scenes/Tasks/helpers';
import { ERRATA_SEARCH_QUERY } from '../HostErrata/HostErrataConstants';

const errorToast = (error) => {
  const message = getResponseErrorMsgs(error.response);
  return message;
};

const baseParams = ({ feature, hostname, inputs = {} }) => ({
  job_invocation: {
    feature,
    inputs,
    search_query: `name ^ (${hostname})`,
  },
});

const katelloPackageInstallParams = ({ hostname, packageName }) =>
  baseParams({
    hostname,
    inputs: { package: packageName },
    feature: REX_FEATURES.KATELLO_PACKAGE_INSTALL,
  });

const katelloTracerResolveParams = ({ hostname, ids }) =>
  baseParams({
    hostname,
    inputs: { ids },
    feature: REX_FEATURES.KATELLO_HOST_TRACER_RESOLVE,
  });

const katelloHostErrataInstallParams = ({
  hostname, search,
}) => baseParams({
  hostname,
  inputs: { [ERRATA_SEARCH_QUERY]: search },
  feature: REX_FEATURES.KATELLO_HOST_ERRATA_INSTALL,
});

export const installPackage = ({ hostname, packageName }) => post({
  type: API_OPERATIONS.POST,
  key: REX_JOB_INVOCATIONS_KEY,
  url: foremanApi.getApiUrl('/job_invocations'),
  params: katelloPackageInstallParams({ hostname, packageName }),
  handleSuccess: response => renderTaskStartedToast({
    humanized: { action: `Install ${packageName} on ${hostname}` },
    id: response?.data?.dynflow_task?.id,
  }),
  errorToast: error => errorToast(error),
});

export const resolveTraces = ({ hostname, ids }) => post({
  type: API_OPERATIONS.POST,
  key: REX_JOB_INVOCATIONS_KEY,
  url: foremanApi.getApiUrl('/job_invocations'),
  params: katelloTracerResolveParams({ hostname, ids }),
  handleSuccess: response => renderTaskStartedToast({
    humanized: { action: `Resolve traces on ${hostname}` },
    id: response?.data?.dynflow_task?.id,
  }),
  errorToast: error => errorToast(error),
});

export const installErrata = ({
  hostname, search,
}) => post({
  type: API_OPERATIONS.POST,
  key: REX_JOB_INVOCATIONS_KEY,
  url: foremanApi.getApiUrl('/job_invocations'),
  params: katelloHostErrataInstallParams({
    hostname, search,
  }),
  handleSuccess: response => renderTaskStartedToast({
    humanized: { action: `Install Errata on ${hostname}` },
    id: response?.data?.dynflow_task?.id,
  }),
  errorToast: error => errorToast(error),
});
