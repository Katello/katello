import { REX_FEATURES } from './RemoteExecutionConstants';
import { KATELLO_TRACER_PACKAGE } from './HostTracesConstants';
import { ERRATA_SEARCH_QUERY } from '../HostErrata/HostErrataConstants';

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

export const errataInstallUrl = ({
  hostname, search,
}) => {
  const params = [
    `feature=${REX_FEATURES.KATELLO_HOST_ERRATA_INSTALL}`,
    `host_ids=name ^ (${hostname})`,
    `inputs[${ERRATA_SEARCH_QUERY}]=${search}`,
  ];
  const urlQuery = encodeURI(params.join('&'));
  return `/job_invocations/new?${urlQuery}`;
};
