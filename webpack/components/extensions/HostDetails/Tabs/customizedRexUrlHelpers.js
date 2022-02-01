import { REX_FEATURES } from './RemoteExecutionConstants';
import { KATELLO_TRACER_PACKAGE, TRACES_SEARCH_QUERY } from './TracesTab/HostTracesConstants';
import { ERRATA_SEARCH_QUERY } from './ErrataTab/HostErrataConstants';
import { PACKAGE_SEARCH_QUERY } from '../ApplicablePackages/ApplicablePackagesConstants';

export const createJob = ({
  hostname, feature, inputs,
}) => {
  const inputParams = Object.keys(inputs).map(key => `inputs[${key}]=${inputs[key]}`);
  const params = [
    `feature=${feature}`,
    `host_ids=name ^ (${hostname})`,
    ...inputParams,
  ];
  const urlQuery = encodeURI(params.join('&'));
  return `/job_invocations/new?${urlQuery}`;
};

export const katelloPackageInstallUrl = ({ hostname }) => createJob({
  hostname,
  feature: REX_FEATURES.KATELLO_PACKAGE_INSTALL,
  inputs: { package: KATELLO_TRACER_PACKAGE },
});

export const katelloPackageInstallBySearchUrl = ({ hostname, search }) => createJob({
  hostname,
  feature: REX_FEATURES.KATELLO_PACKAGE_INSTALL_BY_SEARCH,
  inputs: { [PACKAGE_SEARCH_QUERY]: search },
});

export const resolveTraceUrl = ({ hostname, search }) => createJob({
  hostname,
  feature: REX_FEATURES.KATELLO_HOST_TRACER_RESOLVE,
  inputs: { [TRACES_SEARCH_QUERY]: search },
});

export const errataInstallUrl = ({ hostname, search }) => createJob({
  hostname,
  feature: REX_FEATURES.KATELLO_HOST_ERRATA_INSTALL,
  inputs: { [ERRATA_SEARCH_QUERY]: search },
});
