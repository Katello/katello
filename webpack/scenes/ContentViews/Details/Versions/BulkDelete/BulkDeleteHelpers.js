import { translate as __ } from 'foremanReact/common/I18n';
import { sum } from 'lodash';

export const getNumberOfActivationKeys = versions =>
  sum(versions.map(({ environments }) =>
    sum(environments.map(({ activation_key_count: akCount }) => akCount))));

export const getNumberOfHosts = versions =>
  sum(versions.map(({ environments }) =>
    sum(environments.map(({ host_count: hostCount }) => hostCount))));

// Gets a non-duplicated list of environments from within a given set of versions
export const getEnvironmentList = (versions) => {
  const envIds = [];
  const environmentList = [];
  versions.forEach(({ environments }) => environments.forEach((env) => {
    if (!envIds.includes(env.id)) {
      environmentList.push(env);
      envIds.push(env.id);
    }
  }));
  return environmentList;
};

export const getNumberOfEnvironments = versions => getEnvironmentList(versions).length;

// Creates a string from a list of versions: '3.0' or '3.0 and 2.0' or '3.0, 2.0 and 1.0' etc.
export const getVersionListString = versions => versions.map(({ version }, index) =>
  `${index > 0 && index === (versions.length - 1) ?
    __(' and') : ''} ${version}${versions.length - index > 2 ? ',' : ''}`).join('');
