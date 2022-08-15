import React, { useContext } from 'react';

import { translate as __ } from 'foremanReact/common/I18n';
import { FormattedMessage } from 'react-intl';

import { Label } from '@patternfly/react-core';
import {
  TableComposable,
  TableVariant,
  Tbody,
  Td,
  Th,
  Thead,
  Tr,
} from '@patternfly/react-table';

import WizardHeader from '../../../../components/WizardHeader';
import ActionSummary from '../ActionSummary';
import { BulkDeleteContext } from '../BulkDeleteContextWrapper';
import {
  getNumberOfEnvironments,
  getVersionListString,
} from '../BulkDeleteHelpers';

export default () => {
  const { versions } = useContext(BulkDeleteContext);
  const affectedVersions = versions.filter(({ environments }) => !!environments.length);
  const pluralVersions =
    affectedVersions.length > 1;
  const versionList = getVersionListString(affectedVersions);
  const pluralEnvironments = getNumberOfEnvironments(versions) > 1;

  const columnHeaders = (() => {
    const columnList = [
      __('Environment'),
      __('Hosts'),
      __('Activation keys'),
    ];

    if (pluralVersions) columnList.push(__('Associated version'));

    return columnList;
  })();

  return (
    <>
      <WizardHeader
        title={pluralEnvironments ?
          __('Review affected environments') :
          __('Review affected environment')}
      />
      <ActionSummary
        text={
          <FormattedMessage
            id="bulk-delete-review-environments-removal"
            values={{
              versionOrVersions: pluralVersions ?
                __('Versions') :
                __('Version'),
              versionList,
            }}
            defaultMessage={pluralEnvironments ?
              __('{versionOrVersions} {versionList} will be removed from the listed environments and will no longer be available for promotion.') :
              __('{versionOrVersions} {versionList} will be removed from the listed environment and will no longer be available for promotion.')}
          />}
      />
      <TableComposable ouiaId="bulk-delete-env-table" variant={TableVariant.compact}>
        <Thead>
          <Tr ouiaId="bulk-delete-env-header">
            {columnHeaders.map(col =>
              <Th key={col}>{col}</Th>)}
          </Tr>
        </Thead>
        <Tbody>
          {versions?.map(({
            environments, version,
          }) => environments.map(({
            id,
            name,
            activation_key_count: akCount,
            host_count: hostCount,
          }) => (
            <Tr ouiaId={`${name}_${id}`} key={`${name}_${id}`}>
              <Td>
                <Label
                  /* TODO: Add "isCompact" to this on update of patternfly */
                  isTruncated
                  color="purple"
                >
                  {name}
                </Label>
              </Td>
              <Td>{hostCount}</Td>
              <Td>{akCount}</Td>
              {pluralVersions && <Td>{`${__('Version')} ${version}`}</Td>}
            </Tr>
          )))
          }
        </Tbody>
      </TableComposable>
    </>
  );
};

