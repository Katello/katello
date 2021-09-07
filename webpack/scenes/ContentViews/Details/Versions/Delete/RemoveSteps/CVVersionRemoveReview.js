import React, { useContext } from 'react';
import { useSelector } from 'react-redux';
import { Flex, FlexItem, Label } from '@patternfly/react-core';
import { ExclamationTriangleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectCVActivationKeys, selectCVHosts } from '../../../ContentViewDetailSelectors';
import DeleteContext from '../DeleteContext';

const CVVersionRemoveReview = () => {
  const {
    cvId, versionNameToRemove, versionEnvironments,
    selected, selectedEnvForAK, selectedCVNameForAK, selectedCVNameForHosts,
    selectedEnvForHost, affectedActivationKeys, affectedHosts, deleteFlow,
  } = useContext(DeleteContext);
  const activationKeysResponse = useSelector(state => selectCVActivationKeys(state, cvId));
  const hostsResponse = useSelector(state => selectCVHosts(state, cvId));
  const { results: hostResponse } = hostsResponse;
  const { results: akResponse } = activationKeysResponse;
  const selectedEnv = versionEnvironments.filter((_env, index) => selected[index]);
  const versionDeleteInfo = __(`Version ${versionNameToRemove} will be deleted from all environments. It will no longer be available for promotion.`);
  const removalNotice = __(`Version ${versionNameToRemove} will be removed from environments listed below and stays available for later promotion. ` +
      'Changes listed below will be effective after clicking Remove button.');

  return (
    <>
      <h2>{__('Review Details')}</h2>
      {deleteFlow && versionDeleteInfo}
      {!deleteFlow && removalNotice}
      {(selectedEnv.length !== 0) &&
        <>
          <h3>{__('Environments')}</h3>
          <Flex>
            <FlexItem><ExclamationTriangleIcon /></FlexItem>
            <FlexItem>{__('This version will be removed from:')}</FlexItem>
          </Flex>
          <Flex>
            {selectedEnv?.map(({ name, id }) =>
              <FlexItem key={name}><Label color="purple" href={`/lifecycle_environments/${id}`}>{name}</Label></FlexItem>)}
          </Flex>
        </>}
      {affectedHosts &&
        <>
          <h3>{__('Content hosts')}</h3>
          <Flex>
            <FlexItem><ExclamationTriangleIcon /></FlexItem>
            <FlexItem><p>{__(`${hostResponse.length} host${hostResponse.length > 1 ? 's' : ''} will be moved to content view ${selectedCVNameForHosts} in `)}</p></FlexItem>
            <FlexItem><Label color="purple" href={`/lifecycle_environments/${selectedEnvForHost[0].id}`}>{selectedEnvForHost[0].name}</Label></FlexItem>
          </Flex>
        </>}
      {affectedActivationKeys &&
      <>
        <h3>{__('Activation keys')}</h3>
        <Flex>
          <FlexItem><ExclamationTriangleIcon /></FlexItem>
          <FlexItem><p>{__(`${akResponse.length} activation key${akResponse.length > 1 ? 's' : ''} will be moved to content view ${selectedCVNameForAK} in `)}</p></FlexItem>
          <FlexItem><Label color="purple" href={`/lifecycle_environments/${selectedEnvForAK[0].id}`}>{selectedEnvForAK[0].name}</Label></FlexItem>
        </Flex>
      </>}
    </>
  );
};

export default CVVersionRemoveReview;
