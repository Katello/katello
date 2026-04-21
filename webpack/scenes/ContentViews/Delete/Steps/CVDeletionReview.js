import React, { useContext } from 'react';
import { useSelector } from 'react-redux';
import { Flex, FlexItem, Label } from '@patternfly/react-core';
import { ExclamationTriangleIcon } from '@patternfly/react-icons';
import { FormattedMessage } from 'react-intl';
import { translate as __ } from 'foremanReact/common/I18n';
import CVDeleteContext from '../CVDeleteContext';
import { selectCVActivationKeys, selectCVHosts } from '../../Details/ContentViewDetailSelectors';
import WizardHeader from '../../components/WizardHeader';

const CVDeletionReview = () => {
  const {
    cvId, cvEnvironments, selectedCVNameForHosts,
    selectedEnvForHost, selectedCVNameForAK, selectedEnvForAK,
    selectedCVNameForHostgroups, selectedEnvForHostgroup,
    affectedHosts, affectedActivationKeys, affectedHostgroups,
    cvDetailsResponse,
  } = useContext(CVDeleteContext);
  const activationKeysResponse = useSelector(state => selectCVActivationKeys(state, cvId));
  const hostsResponse = useSelector(state => selectCVHosts(state, cvId));
  const { results: hostResponse } = hostsResponse || {};
  const { results: akResponse } = activationKeysResponse || {};
  const { hostgroups = [] } = cvDetailsResponse || {};
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
              <FlexItem key={name}><Label color="purple" href={`/lifecycle_environments/${id}`}>{name}</Label></FlexItem>)}
          </Flex>
        </>}
      {affectedHosts &&
        <>
          <h3>{__('Content hosts')}</h3>
          <Flex>
            <FlexItem><ExclamationTriangleIcon /></FlexItem>
            <FlexItem>
              <p>
                <FormattedMessage
                  id="cv-deletion-hosts-message"
                  defaultMessage="{count, plural, one {# host} other {# hosts}} will be moved to content view {cvName} in "
                  values={{
                    count: hostResponse.length,
                    cvName: selectedCVNameForHosts,
                  }}
                />
              </p>
            </FlexItem>
            <FlexItem><Label color="purple" href={`/lifecycle_environments/${selectedEnvForHost[0].id}`}>{selectedEnvForHost[0].name}</Label></FlexItem>
          </Flex>
        </>}
      {affectedHostgroups &&
        <>
          <h3>{__('Host groups')}</h3>
          <Flex>
            <FlexItem><ExclamationTriangleIcon /></FlexItem>
            <FlexItem>
              <p>
                <FormattedMessage
                  id="cv-deletion-hostgroups-message"
                  defaultMessage="{count, plural, one {# host group} other {# host groups}} will be moved to content view {cvName} in "
                  values={{
                    count: hostgroups.length,
                    cvName: selectedCVNameForHostgroups,
                  }}
                />
              </p>
            </FlexItem>
            <FlexItem><Label color="purple" href={`/lifecycle_environments/${selectedEnvForHostgroup[0].id}`}>{selectedEnvForHostgroup[0].name}</Label></FlexItem>
          </Flex>
        </>}
      {affectedActivationKeys &&
        <>
          <h3>{__('Activation keys')}</h3>
          <Flex>
            <FlexItem><ExclamationTriangleIcon /></FlexItem>
            <FlexItem>
              <p>
                <FormattedMessage
                  id="cv-deletion-activation-keys-message"
                  defaultMessage="{count, plural, one {# activation key} other {# activation keys}} will be moved to content view {cvName} in "
                  values={{
                    count: akResponse.length,
                    cvName: selectedCVNameForAK,
                  }}
                />
              </p>
            </FlexItem>
            <FlexItem><Label color="purple" href={`/lifecycle_environments/${selectedEnvForAK[0].id}`}>{selectedEnvForAK[0].name}</Label></FlexItem>
          </Flex>
        </>}
    </>
  );
};

export default CVDeletionReview;
