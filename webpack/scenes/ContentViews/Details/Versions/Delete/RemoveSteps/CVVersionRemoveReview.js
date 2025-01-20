import React, { useContext, useState } from 'react';
import { useSelector } from 'react-redux';
import { Alert, Flex, FlexItem, Label, AlertActionCloseButton } from '@patternfly/react-core';
import { ExclamationTriangleIcon } from '@patternfly/react-icons';
import { FormattedMessage } from 'react-intl';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectCVActivationKeys, selectCVHosts, selectCVVersions } from '../../../ContentViewDetailSelectors';
import DeleteContext from '../DeleteContext';
import WizardHeader from '../../../../components/WizardHeader';

const CVVersionRemoveReview = () => {
  const [alertDismissed, setAlertDismissed] = useState(false);
  const {
    cvId, versionIdToRemove, versionNameToRemove, selectedEnvSet,
    selectedEnvForAK, selectedCVNameForAK, selectedCVNameForHosts,
    selectedEnvForHost, affectedActivationKeys, affectedHosts, deleteFlow, removeDeletionFlow,
  } = useContext(DeleteContext);
  const activationKeysResponse = useSelector(state => selectCVActivationKeys(state, cvId));
  const hostsResponse = useSelector(state => selectCVHosts(state, cvId));
  const { results: hostResponse = [] } = hostsResponse || {};
  const { results: akResponse = [] } = activationKeysResponse || {};
  const cvVersions = useSelector(state => selectCVVersions(state, cvId));
  const versionDeleteInfo = __(`Version ${versionNameToRemove} will be deleted from all environments. It will no longer be available for promotion.`);
  const removalNotice = __(`Version ${versionNameToRemove} will be removed from the environments listed below, and will remain available for later promotion. ` +
    'Changes listed below will be effective after clicking Remove.');

  const matchedCVResults = cvVersions?.results?.filter(cv => cv.id === versionIdToRemove) || [];
  const selectedCVE = matchedCVResults
    .flatMap(cv => cv.content_view_environments || [])
    .filter(env => selectedEnvSet.has(env.environment_id));

  const multiCVHosts = hostResponse?.filter(host =>
    host.content_facet_attributes?.multi_content_view_environment) || [];
  const multiCVHostsCount = multiCVHosts.length;

  const singleCVHostsCount = (hostResponse?.length || 0) - multiCVHostsCount;

  const multiCVActivationKeys = akResponse.filter(key => key.multi_content_view_environment);
  const multiCVActivationKeysCount = multiCVActivationKeys.length;

  const singleCVActivationKeysCount = akResponse.length - multiCVActivationKeysCount;

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
      {(selectedCVE?.length !== 0) &&
        <>
          <h3>{__('Environments')}</h3>
          <Flex>
            <FlexItem><ExclamationTriangleIcon /></FlexItem>
            <FlexItem style={{ marginBottom: '0.5em' }}>{__('This version will be removed from:')}</FlexItem>
          </Flex>
          <Flex>
            {selectedCVE?.map(({ environment_name: name, environment_id: id }) =>
              <FlexItem key={name}><Label isTruncated color="purple" href={`/lifecycle_environments/${id}`}>{name}</Label></FlexItem>)}
          </Flex>
        </>}
      {affectedHosts &&
        <>
          <h3>{__('Content hosts')}</h3>
          {singleCVHostsCount > 0 && (
            <Flex>
              <FlexItem><ExclamationTriangleIcon /></FlexItem>
              <FlexItem data-testid="single-cv-hosts-remove">
                <FormattedMessage
                  id="single-cv-hosts-remove"
                  defaultMessage="{count, plural, one {# {singular}} other {# {plural}}} will be moved to content view {cvName} in {envName}."
                  values={{
                    count: singleCVHostsCount,
                    singular: __('host'),
                    plural: __('hosts'),
                    cvName: selectedCVNameForHosts,
                    envName: selectedEnvForHost[0] && (
                      <Label isTruncated color="purple" href={`/lifecycle_environments/${selectedEnvForHost[0].id}`}>
                        {selectedEnvForHost[0].name}
                      </Label>
                    ),
                  }}
                />
              </FlexItem>
            </Flex>
          )}
          {multiCVHostsCount > 0 && (
            <Flex>
              <FlexItem><ExclamationTriangleIcon /></FlexItem>
              <FlexItem>
                <FormattedMessage
                  id="multi-cv-hosts-remove"
                  defaultMessage="{envSingularOrPlural} {envCV} will be removed from {hostCount, plural, one {# {hostSingular}} other {# {hostPlural}}}."
                  values={{
                    envSingularOrPlural: (
                      <FormattedMessage
                        id="environment.plural"
                        defaultMessage="{count, plural, one {{envSingular}} other {{envPlural}}}"
                        values={{
                          count: selectedCVE?.length,
                          envSingular: __('Content view environment'),
                          envPlural: __('Content view environments'),
                        }}
                      />
                    ),
                    envCV: selectedCVE
                      ?.map(cve => cve.label)
                      .join(', '),
                    hostCount: multiCVHostsCount,
                    hostSingular: __('multi-environment host'),
                    hostPlural: __('multi-environment hosts'),
                  }}
                />
              </FlexItem>
            </Flex>
          )}
        </>}
      {affectedActivationKeys &&
        <>
          <h3>{__('Activation keys')}</h3>
          {singleCVActivationKeysCount > 0 && (
            <Flex>
              <FlexItem><ExclamationTriangleIcon /></FlexItem>
              <FlexItem data-testid="single-cv-activation-keys-remove">
                <FormattedMessage
                  id="single-cv-activation-keys-remove"
                  defaultMessage="{count, plural, one {# {singular}} other {# {plural}}} will be moved to content view {cvName} in {envName}."
                  values={{
                    count: singleCVActivationKeysCount,
                    singular: __('activation key'),
                    plural: __('activation keys'),
                    cvName: selectedCVNameForAK,
                    envName: selectedEnvForAK[0] && (
                      <Label isTruncated color="purple" href={`/lifecycle_environments/${selectedEnvForAK[0].id}`}>
                        {selectedEnvForAK[0].name}
                      </Label>
                    ),
                  }}
                />
              </FlexItem>
            </Flex>
          )}
          {multiCVActivationKeysCount > 0 && (
            <Flex>
              <FlexItem><ExclamationTriangleIcon /></FlexItem>
              <FlexItem>
                <FormattedMessage
                  id="multi-cv-activation-keys-remove"
                  defaultMessage="{envSingularOrPlural} {envCV} will be removed from {akCount, plural, one {# {keySingular}} other {# {keyPlural}}}."
                  values={{
                    envSingularOrPlural: (
                      <FormattedMessage
                        id="environment.plural"
                        defaultMessage="{count, plural, one {{envSingular}} other {{envPlural}}}"
                        values={{
                          count: selectedCVE?.length,
                          envSingular: __('Content view environment'),
                          envPlural: __('Content view environments'),
                        }}
                      />
                    ),
                    envCV: selectedCVE
                      ?.map(cve => cve.label)
                      .join(', '),
                    akCount: multiCVActivationKeysCount,
                    keySingular: __('multi-environment activation key'),
                    keyPlural: __('multi-environment activation keys'),
                  }}
                />
              </FlexItem>
            </Flex>
          )}
        </>}
    </>
  );
};

export default CVVersionRemoveReview;
