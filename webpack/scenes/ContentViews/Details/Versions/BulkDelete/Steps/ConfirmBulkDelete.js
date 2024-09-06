import React, { useContext } from 'react';

import { translate as __ } from 'foremanReact/common/I18n';
import { first } from 'lodash';
import { FormattedMessage } from 'react-intl';
import { useSelector } from 'react-redux';

import {
  Flex,
  FlexItem,
  Label,
} from '@patternfly/react-core';

import WizardHeader from '../../../../components/WizardHeader';
import { selectContentViews } from '../../../../ContentViewSelectors';
import ActionSummary from '../ActionSummary';
import { BulkDeleteContext } from '../BulkDeleteContextWrapper';
import {
  getEnvironmentList,
  getNumberOfActivationKeys,
  getNumberOfHosts,
  getVersionListString,
} from '../BulkDeleteHelpers';

export default () => {
  const {
    versions, selectedCVForHosts, selectedEnvForHosts, selectedCVForAK, selectedEnvForAK,
  } = useContext(BulkDeleteContext);
  const { results: contentViewResults = [] } = useSelector(selectContentViews);
  const versionList = getVersionListString(versions);
  const numberOfActivationKeys = getNumberOfActivationKeys(versions);
  const numberOfHosts = getNumberOfHosts(versions);
  const affectedVersions = versions.filter(({ environments }) => !!environments.length);
  const affectedVersionsListString = getVersionListString(affectedVersions);
  const environments = getEnvironmentList(versions);
  const pluralEnvironments = environments.length > 1;

  return (
    <>
      <WizardHeader
        title={__('Review details')}
      />
      <ActionSummary
        title={__('Versions')}
        text={<FormattedMessage
          id="bulk-delete-summary-versions"
          values={{
            versionList,
            versionOrVersions: versions.length > 1 ?
              __('Versions') : __('Version'),
          }}
          defaultMessage={__('{versionOrVersions} {versionList} will be deleted and will no longer be available for promotion.')}
        />}
      />
      {!!affectedVersions.length &&
        <div>
          <ActionSummary
            title={__('Environments')}
            text={
              <FormattedMessage
                id="bulk-delete-summary-environments"
                values={{
                  versionList: affectedVersionsListString,
                  versionOrVersions: affectedVersions.length > 1 ? __('Versions ') : __('Version '),
                  envLabel: (() => {
                    const { id, name } = first(environments);
                    return <Label color="purple" href={`/lifecycle_environments/${id}`}>{name}</Label>;
                  })(),
                }}
                defaultMessage={pluralEnvironments ?
                  __('{versionOrVersions} {versionList} will be removed from the following environments:') :
                  __('{versionOrVersions} {versionList} will be removed from the {envLabel} environment.')}
              />
            }
          />
          {pluralEnvironments &&
            <Flex>
              {environments.map(({ name, id }) => (
                <FlexItem key={id}>
                  <Label color="purple" href={`/lifecycle_environments/${id}`}>{name}</Label>
                </FlexItem>))
              }
            </Flex>}
        </div>
      }
      {!!numberOfHosts &&
        <ActionSummary
          title={__('Hosts')}
          text={
            <FormattedMessage
              id="bulk-delete-summary-hosts"
              values={{
                numberOfHosts,
                cvName: contentViewResults
                  .find(({ id }) => id === selectedCVForHosts)?.name || '',
              }}
              defaultMessage={numberOfHosts > 1 ?
                __('{numberOfHosts} hosts will be assigned to content view {cvName} in') :
                __('{numberOfHosts} host will be assigned to content view {cvName} in')}
            />
          }
          selectedEnv={first(selectedEnvForHosts)}
        />}
      {!!numberOfActivationKeys &&
        <ActionSummary
          title={__('Activation keys')}
          text={
            <FormattedMessage
              id="bulk-delete-summary-activation-keys"
              values={{
                numberOfActivationKeys,
                cvName: contentViewResults
                  .find(({ id }) => id === selectedCVForAK)?.name || '',
              }}
              defaultMessage={numberOfActivationKeys > 1 ?
                __('{numberOfActivationKeys} activation keys will be assigned to content view {cvName} in') :
                __('{numberOfActivationKeys} activation key will be assigned to content view {cvName} in')}
            />
          }
          selectedEnv={first(selectedEnvForAK)}
        />
      }
    </>
  );
};

