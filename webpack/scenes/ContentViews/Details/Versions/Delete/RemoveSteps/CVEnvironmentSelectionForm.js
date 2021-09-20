import React, { useEffect, useState, useContext } from 'react';
import { Alert, Checkbox, EmptyState, EmptyStateVariant, Title, EmptyStateBody } from '@patternfly/react-core';
import { TableVariant, TableComposable, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import DeleteContext from '../DeleteContext';

const CVEnvironmentSelectionForm = () => {
  const {
    versionNameToRemove, versionEnvironments, selected, setSelected,
    setAffectedActivationKeys, setAffectedHosts, deleteFlow,
    removeDeletionFlow, setRemoveDeletionFlow,
  } = useContext(DeleteContext);

  const [allRowsSelected, setAllRowsSelected] = useState(deleteFlow);
  const onSelect = (event, isSelected, rowId) => {
    const newSelected = selected.map((sel, index) => (index === rowId ? isSelected : sel));
    setSelected(newSelected);

    if (!isSelected && allRowsSelected) {
      setAllRowsSelected(false);
      setRemoveDeletionFlow(false);
    } else if (isSelected && !allRowsSelected) {
      let allSelected = true;
      for (let i = 0; i < selected.length; i += 1) {
        if (i !== rowId) {
          if (!selected[i]) {
            allSelected = false;
          }
        }
      }
      if (allSelected) {
        setAllRowsSelected(true);
      }
    }
  };

  useEffect(() => {
    const selectedEnv = versionEnvironments.filter((_env, index) => selected[index]);
    setAffectedActivationKeys(!!(selectedEnv.filter(env => env.activation_key_count > 0).length));
    setAffectedHosts(!!(selectedEnv.filter(env => env.host_count > 0).length));
  }, [setSelected, selected, setAffectedActivationKeys, setAffectedHosts, versionEnvironments]);

  const onSelectAll = (event, isSelected) => {
    setAllRowsSelected(isSelected);
    if (!isSelected) setRemoveDeletionFlow(false);
    setSelected(selected.map(_sel => isSelected));
  };

  const columnHeaders = [
    __('Environment'),
    __('Hosts'),
    __('Activation keys'),
  ];

  const versionDeleteInfo = __(`Version ${versionNameToRemove} will be deleted from the listed environments. It will no longer be available for promotion.`);
  const versionRemovalInfo = __('Removing this version from all environments will not delete the version. Version will still be available for later promotion.');
  const versionEnvironmentsEmptyInfo = __(`Version ${versionNameToRemove} has not been promoted to any environments. ` +
    'You can delete this version completely and it will no longer be available for promotion.');
  return (
    <>
      {(!deleteFlow &&
        (removeDeletionFlow || allRowsSelected || versionEnvironments.length === 0))
      && (
      <Alert variant="warning" isInline title={__('Warning')}>
        <p style={{ marginBottom: '0.5em' }}>{removeDeletionFlow ? versionDeleteInfo : versionRemovalInfo}</p>
        <Checkbox
          id="delete_version"
          label={__('Delete version')}
          isChecked={removeDeletionFlow}
          onChange={checked => setRemoveDeletionFlow(checked)}
          style={{ margin: 0 }}
        />
      </Alert>)}
      {(versionEnvironments.length !== 0) &&
      <TableComposable variant={TableVariant.compact}>
        <Thead>
          <Tr>
            <Td
              select={{
              onSelect: onSelectAll,
              isSelected: allRowsSelected || deleteFlow || removeDeletionFlow,
              disable: deleteFlow || removeDeletionFlow,
              }}
            />
            {columnHeaders.map(col =>
              <Th key={col}>{col}</Th>)}
          </Tr>
        </Thead>
        <Tbody>
          {versionEnvironments?.map((env, rowIndex) => {
            const {
              id, name, activation_key_count: akCount, host_count: hostCount,
            } = env;
            return (
              <Tr key={`${name}_${id}`}>
                <Td
                  key={`${name}__${id}_select`}
                  select={{
                    rowIndex,
                    onSelect,
                    isSelected: selected[rowIndex] || deleteFlow || removeDeletionFlow,
                    disable: deleteFlow || removeDeletionFlow,
                  }}
                />
                <Td>
                  {name}
                </Td>
                <Td>{hostCount}</Td>
                <Td>{akCount}</Td>
              </Tr>
            );
          })
          }
        </Tbody>
      </TableComposable>}
      {(versionEnvironments.length === 0) &&
      <EmptyState variant={EmptyStateVariant.xs}>
        <Title headingLevel="h4" size="md">
          {__('This version has not been promoted to any environments.')}
        </Title>
        <EmptyStateBody>
          {versionEnvironmentsEmptyInfo}
        </EmptyStateBody>
      </EmptyState>}
    </>
  );
};

export default CVEnvironmentSelectionForm;
