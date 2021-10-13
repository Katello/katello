import { REX_FEATURES } from './RemoteExecutionConstants';
import { KATELLO_TRACER_PACKAGE } from './HostTracesConstants';

export const katelloPackageInstallUrl = ({ hostname }) => {
  const urlQuery = encodeURI([
    `feature=${REX_FEATURES.KATELLO_PACKAGE_INSTALL}`,
    `inputs[package]=${KATELLO_TRACER_PACKAGE}`,
    `host_ids=name ^ (${hostname})`,
  ].join('&'));
  return `/job_invocations/new?${urlQuery}`;
};

export const resolveTraceUrl = ({ hostname, ids }) => {
  const urlQuery = encodeURI([
    `feature=${REX_FEATURES.KATELLO_HOST_TRACER_RESOLVE}`,
    `inputs[ids]=${ids.join(',')}`,
    `host_ids=name ^ (${hostname})`,
  ].join('&'));
  return `/job_invocations/new?${urlQuery}`;
};
