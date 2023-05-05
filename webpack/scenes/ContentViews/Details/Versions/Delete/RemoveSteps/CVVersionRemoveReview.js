import React, { useContext, useState } from 'react';
import { useSelector } from 'react-redux';
import { Alert, Flex, FlexItem, Label, AlertActionCloseButton } from '@patternfly/react-core';
import { ExclamationTriangleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectCVActivationKeys, selectCVHosts } from '../../../ContentViewDetailSelectors';
import DeleteContext from '../DeleteContext';
import { pluralize } from '../../../../../../utils/helpers';
import WizardHeader from '../../../../components/WizardHeader';

const CVVersionRemoveReview = () => {
  const [alertDismissed, setAlertDismissed] = useState(false);
  const {
    cvId, versionNameToRemove, versionEnvironments, selectedEnvSet,
    selectedEnvForAK, selectedCVNameForAK, selectedCVNameForHosts,
    selectedEnvForHost, affectedActivationKeys, affectedHosts, deleteFlow, removeDeletionFlow,
  } = useContext(DeleteContext);
  const activationKeysResponse = useSelector(state => selectCVActivationKeys(state, cvId));
  const hostsResponse = useSelector(state => selectCVHosts(state, cvId));
  const { results: hostResponse } = hostsResponse;
  const { results: akResponse } = activationKeysResponse;
  const selectedEnv = versionEnvironments.filter(env => selectedEnvSet.has(env.id));
  const versionDeleteInfo = __(`Version ${versionNameToRemove} will be deleted from all environments. It will no longer be available for promotion.`);
  const removalNotice = __(`Version ${versionNameToRemove} will be removed from the environments listed below, and will remain available for later promotion. ` +
    'Changes listed below will be effective after clicking Remove.');

  return (
    <>
      <WizardHeader title={__('Review details')} />
      {!alertDismissed && (deleteFlow || removeDeletionFlow) &&
        <Alert
          ouiaId="cvv-remove-review-alert"
          variant="warning"
          isInline
          title={__('Warning')}
          actionClose={<AlertActionCloseButton onClose={() => setAlertDismissed(true)} />}
        >
          <p style={{ marginBottom: '0.5em' }}>{versionDeleteInfo}</p>
        </Alert>}
      {!(deleteFlow || removeDeletionFlow) && <WizardHeader description={removalNotice} />}
      {(selectedEnv.length !== 0) &&
        <>
          <h3>{__('Environments')}</h3>
          <Flex>
            <FlexItem><ExclamationTriangleIcon /></FlexItem>
            <FlexItem style={{ marginBottom: '0.5em' }}>{__('This version will be removed from:')}</FlexItem>
          </Flex>
          <Flex>
            {selectedEnv?.map(({ name, id }) =>
              <FlexItem key={name}><Label isTruncated color="purple" href={`/lifecycle_environments/${id}`}>{name}</Label></FlexItem>)}
          </Flex>
        </>}
      {affectedHosts &&
        <>
          <h3>{__('Content hosts')}</h3>
          <Flex>
            <FlexItem><ExclamationTriangleIcon /></FlexItem>
            <FlexItem><p>{__(`${pluralize(hostResponse.length, 'host')} will be moved to content view ${selectedCVNameForHosts} in `)}</p></FlexItem>
            <FlexItem><Label isTruncated color="purple" href={`/lifecycle_environments/${selectedEnvForHost[0].id}`}>{selectedEnvForHost[0].name}</Label></FlexItem>
          </Flex>
        </>}
      {affectedActivationKeys &&
        <>
          <h3>{__('Activation keys')}</h3>
          <Flex>
            <FlexItem><ExclamationTriangleIcon /></FlexItem>
            <FlexItem><p>{__(`${pluralize(akResponse.length, 'activation key')} will be moved to content view ${selectedCVNameForAK} in `)}</p></FlexItem>
            <FlexItem><Label isTruncated color="purple" href={`/lifecycle_environments/${selectedEnvForAK[0].id}`}>{selectedEnvForAK[0].name}</Label></FlexItem>
          </Flex>
        </>}
    </>
  );
};

export default CVVersionRemoveReview;
