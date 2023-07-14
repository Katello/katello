import { propsToCamelCase } from 'foremanReact/common/helpers';

export const REMOTE_EXECUTION = 'remoteExecution';
export const KATELLO_AGENT = 'katelloAgent';


export const akIsNotRegistered = ({ akDetails }) => {
  const {
    purpose_usage: purposeUsage,
    purpose_role: purposeRole,
    release_version: releaseVersion,
    service_level: serviceLevel,
  } = akDetails;
  return !purposeUsage?.uuid;
};

export const akIsRegistered = ({ akDetails }) => !akIsNotRegistered({ akDetails });

export const akHasRequiredPermissions = (requiredPermissions = [], userPermissions = {}) => {
  const permittedActions = Object.keys(userPermissions).filter(key => userPermissions[key]);
  return requiredPermissions.every(permission => permittedActions.includes(permission));
};
