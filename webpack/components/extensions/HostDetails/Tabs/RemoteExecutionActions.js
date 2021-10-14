import { API_OPERATIONS, post } from 'foremanReact/redux/API';
import { REX_JOB_INVOCATIONS_KEY, REX_FEATURES } from './RemoteExecutionConstants';
import { foremanApi } from '../../../../services/api';
import { getResponseErrorMsgs } from '../../../../utils/helpers';
import { renderTaskStartedToast } from '../../../../scenes/Tasks/helpers';
import { errataInclusionType } from '../HostErrata/HostErrataConstants';

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
  hostname, errata, all = false, search,
}) => {
  const inputs = { 'Inclusion Type': errataInclusionType(all) };
  if (errata) {
    inputs.errata = errata;
  }
  if (all && search) {
    inputs['Filter Errata'] = search;
  }

  return baseParams({
    hostname,
    inputs,
    feature: REX_FEATURES.KATELLO_HOST_ERRATA_INSTALL,
  });
};

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
  hostname, errata, all = false, search,
}) => post({
  type: API_OPERATIONS.POST,
  key: REX_JOB_INVOCATIONS_KEY,
  url: foremanApi.getApiUrl('/job_invocations'),
  params: katelloHostErrataInstallParams({
    hostname, errata, all, search,
  }),
  handleSuccess: response => renderTaskStartedToast({
    humanized: { action: `Install Errata on ${hostname}` },
    id: response?.data?.dynflow_task?.id,
  }),
  errorToast: error => errorToast(error),
});
