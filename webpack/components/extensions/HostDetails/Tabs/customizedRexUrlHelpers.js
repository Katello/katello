import { REX_FEATURES } from './RemoteExecutionConstants';
import { TRACES_SEARCH_QUERY } from './TracesTab/HostTracesConstants';
import { ERRATA_SEARCH_QUERY } from './ErrataTab/HostErrataConstants';
import { PACKAGE_SEARCH_QUERY } from './PackagesTab/YumInstallablePackagesConstants';
import { PACKAGES_SEARCH_QUERY, SELECTED_UPDATE_VERSIONS } from './PackagesTab/HostPackagesConstants';

export const createJob = (options) => {
  const {
    hostname, hostSearch, feature, inputs,
  } = options;
  if (inputs[SELECTED_UPDATE_VERSIONS] === undefined) delete inputs[SELECTED_UPDATE_VERSIONS];
  const inputParams = Object.keys(inputs).map(key => `inputs[${key}]=${inputs[key]}`);
  const search = hostSearch ?? `name ^ (${hostname})`;
  const params = [
    `feature=${feature}`,
    `search=${search}`,
    ...inputParams,
  ];
  const urlQuery = encodeURI(params.join('&'));
  return `/job_invocations/new?${urlQuery}`;
};

export const katelloPackageInstallUrl = ({ hostname, packages }) => createJob({
  hostname,
  feature: REX_FEATURES.KATELLO_PACKAGE_INSTALL,
  inputs: { package: packages },
});

export const katelloPackageInstallBySearchUrl = ({ hostname, hostSearch, search }) => createJob({
  hostname,
  hostSearch,
  feature: REX_FEATURES.KATELLO_PACKAGE_INSTALL_BY_SEARCH,
  inputs: { [PACKAGE_SEARCH_QUERY]: search },
});

export const katelloPackageUpdateUrl = ({ hostname, packageName }) => createJob({
  hostname,
  feature: REX_FEATURES.KATELLO_PACKAGE_UPDATE,
  inputs: { package: packageName },
});

export const packagesUpdateUrl = ({
  hostname, hostSearch, search, versions,
}) => createJob({
  hostname,
  hostSearch,
  feature: REX_FEATURES.KATELLO_PACKAGES_UPDATE_BY_SEARCH,
  inputs: { [PACKAGES_SEARCH_QUERY]: search, [SELECTED_UPDATE_VERSIONS]: versions },
});

export const resolveTraceUrl = ({ hostname, search }) => createJob({
  hostname,
  feature: REX_FEATURES.KATELLO_HOST_TRACER_RESOLVE,
  inputs: { [TRACES_SEARCH_QUERY]: search },
});

export const errataInstallUrl = ({ hostname, search }) => createJob({
  hostname,
  feature: REX_FEATURES.KATELLO_HOST_ERRATA_INSTALL_BY_SEARCH,
  inputs: { [ERRATA_SEARCH_QUERY]: search },
});

export const katelloModuleStreamActionUrl = ({ hostname, action, moduleSpec }) => createJob({
  hostname,
  feature: REX_FEATURES.KATELLO_HOST_MODULE_STREAM_ACTION,
  inputs: { action, module_spec: moduleSpec },
});
