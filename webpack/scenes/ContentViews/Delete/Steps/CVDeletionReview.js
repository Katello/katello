import React, { useContext } from 'react';
import { useSelector } from 'react-redux';
import { Flex, FlexItem, Label } from '@patternfly/react-core';
import { ExclamationTriangleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import CVDeleteContext from '../CVDeleteContext';
import { selectCVActivationKeys, selectCVHosts } from '../../Details/ContentViewDetailSelectors';
import { pluralize } from '../../../../utils/helpers';
import WizardHeader from '../../components/WizardHeader';

const CVDeletionReview = () => {
  const {
    cvId, cvEnvironments, selectedCVNameForHosts,
    selectedEnvForHost, selectedCVNameForAK, selectedEnvForAK,
    affectedHosts, affectedActivationKeys,
  } = useContext(CVDeleteContext);
  const activationKeysResponse = useSelector(state => selectCVActivationKeys(state, cvId));
  const hostsResponse = useSelector(state => selectCVHosts(state, cvId));
  const { results: hostResponse } = hostsResponse || {};
  const { results: akResponse } = activationKeysResponse || {};
  return (
    <>
      <WizardHeader
        title={__('Review details')}
        description={cvEnvironments.length ?
          (__('This content view will be deleted along with all versions from the environments listed below. ' +
            'Changes listed below will be effective after clicking Delete.')) :
          (__('This content view will be deleted. Changes will be effective after clicking Delete.'))}
      />
      {(cvEnvironments.length !== 0) &&
        <>
          <h3>{__('Environments')}</h3>
          <Flex>
            <FlexItem><ExclamationTriangleIcon /></FlexItem>
            <FlexItem style={{ marginBottom: '0.5em' }}>{__('All versions will be removed from these environments')}</FlexItem>
          </Flex>
          <Flex>
            {cvEnvironments?.map(({ name, id }) =>
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

export default CVDeletionReview;
