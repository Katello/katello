import { propsToCamelCase } from 'foremanReact/common/helpers';

export const REMOTE_EXECUTION = 'remoteExecution';
export const KATELLO_AGENT = 'katelloAgent';

const defaultRemoteActionMethod = ({ hostDetails }) => {
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

export default defaultRemoteActionMethod;
