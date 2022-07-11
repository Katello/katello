import { propsToCamelCase } from 'foremanReact/common/helpers';

export const REMOTE_EXECUTION = 'remoteExecution';
export const KATELLO_AGENT = 'katelloAgent';

export const defaultRemoteActionMethod = ({ hostDetails }) => {
  const {
    content_facet_attributes: contentFacetAttributes,
  } = hostDetails;
  const contentFacet = propsToCamelCase(contentFacetAttributes ?? {});
  const katelloAgentAvailable = (contentFacet.katelloAgentInstalled &&
    contentFacet.katelloAgentEnabled);
  if (contentFacet.remoteExecutionByDefault || !katelloAgentAvailable) {
    return REMOTE_EXECUTION;
  }
  return KATELLO_AGENT;
};

export const hostIsNotRegistered = ({ hostDetails }) => {
  const {
    subscription_facet_attributes: subscriptionFacetAttributes,
  } = hostDetails;
  return !subscriptionFacetAttributes?.uuid;
};

export const hostIsRegistered = ({ hostDetails }) => !hostIsNotRegistered({ hostDetails });

export const userPermissionsFromHostDetails = ({ hostDetails }) => {
  const {
    permissions: hostPermissions,
    content_facet_attributes: cfAttributes = {},
  } = hostDetails;
  return { ...hostPermissions, ...cfAttributes?.permissions };
};

// requiredPermissions is an array
// userPermissions is an object, e.g. { view_hosts: true }
export const hasRequiredPermissions = (requiredPermissions = [], userPermissions = {}) => {
  const permittedActions = Object.keys(userPermissions).filter(key => userPermissions[key]);
  return requiredPermissions.every(permission => permittedActions.includes(permission));
};

export const missingRequiredPermissions = (requiredPermissions = [], userPermissions) =>
  !hasRequiredPermissions(requiredPermissions, userPermissions);

export default defaultRemoteActionMethod;
