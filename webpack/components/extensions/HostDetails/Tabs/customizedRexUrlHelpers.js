import { REX_FEATURES } from './RemoteExecutionConstants';
import { KATELLO_TRACER_PACKAGE } from './HostTracesConstants';
import { errataInclusionType } from '../HostErrata/HostErrataConstants';

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
  hostname, ids, all, search,
}) => {
  const params = [
    `feature=${REX_FEATURES.KATELLO_HOST_ERRATA_INSTALL}`,
    `inputs[errata]=${ids.join(',')}`,
    `host_ids=name ^ (${hostname})`,
  ];
  params.push(`inputs[Inclusion Type]=${errataInclusionType(all)}`);

  if (all && search) {
    params.push(`inputs[Filter Errata]=${search}`);
  }
  const urlQuery = encodeURI(params.join('&'));
  return `/job_invocations/new?${urlQuery}`;
};
