import React, { useState, useCallback } from 'react';
import { Skeleton, Button } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { useSelector, useDispatch } from 'react-redux';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import TableWrapper from '../../../Table/TableWrapper';
import useSet from '../../../Table/TableHooks';
import { getHostTraces, resolveHostTraces } from './HostTracesActions';
import { selectHostTracesStatus } from './HostTracesSelectors';
import './TracesTab.scss';

const TracesTab = () => {
  const [searchQuery, updateSearchQuery] = useState('');
  const [selectedTraces, forceRender] = useSet([]);
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const dispatch = useDispatch();
  const { id: hostId } = hostDetails;
  const emptyContentTitle = __('This host currently does not have traces.');
  const emptyContentBody = __('Add traces by installing katello-host-tools-tracer, and applying updates.');
  const emptySearchTitle = __('No matching traces found');
  const emptySearchBody = __('Try changing your search settings.');
  const fetchItems = useCallback(
    params =>
      (hostId ? getHostTraces(hostId, params) : null),
    [hostId],
  );
  const response = useSelector(state => selectAPIResponse(state, 'HOST_TRACES'));
  const { results, ...meta } = response;
  const onRestartApp = () => {
    dispatch(resolveHostTraces(hostId, { trace_ids: [...selectedTraces] }, dispatch));
    selectedTraces.clear();
    dispatch(getHostTraces(hostId, meta));
  };
  const actionButtons = (
    <Button
      variant="danger"
      isDisabled={!selectedTraces.size}
      onClick={onRestartApp}
    >
      {__('Restart app')}
    </Button>
  );
  const status = useSelector(state => selectHostTracesStatus(state));
  const resultIds = results?.map(result => result.id) ?? [];
  const areAllRowsOnPageSelected = () =>
    Number(resultIds?.length) > 0 && resultIds.every(result => selectedTraces.has(result));
  const areAllRowsSelected = () =>
    Number(selectedTraces.size) > 0 && selectedTraces.size === Number(meta.total);
  const selectPage = () => {
    [...results.map(result => result.id)].forEach(id => selectedTraces.add(id));
    forceRender();
  };
  const selectNone = () => {
    selectedTraces.clear();
    forceRender();
  };
  const selectAll = () => {
    // leaving blank until we can implement selectAll Katello-wide
  };

  const onRowSelect = ({ isSelected, traceId }) => {
    if (isSelected) {
      selectedTraces.add(traceId);
    } else {
      selectedTraces.delete(traceId);
    }
    forceRender(); // since changing the ref won't cause a rerender
  };
  if (!hostId) return <Skeleton />;

  /* eslint-disable max-len */

  return (
    <div id="traces-tab">
      <h3>{__('Tracer helps administrators identify applications that need to be restarted after a system is patched.')}</h3>
      <TableWrapper
        actionButtons={actionButtons}
        searchQuery={searchQuery}
        emptyContentBody={emptyContentBody}
        emptyContentTitle={emptyContentTitle}
        emptySearchBody={emptySearchBody}
        emptySearchTitle={emptySearchTitle}
        updateSearchQuery={updateSearchQuery}
        fetchItems={fetchItems}
        autocompleteEndpoint={`/hosts/${hostId}/traces/auto_complete_search`}
        foremanApiAutoComplete
        displaySelectAllCheckbox
        selectPage={selectPage}
        selectNone={selectNone}
        selectAll={selectAll}
        rowsCount={results?.length}
        areAllRowsOnPageSelected={areAllRowsOnPageSelected}
        areAllRowsSelected={areAllRowsSelected}
        variant={TableVariant.compact}
        status={status}
        metadata={meta}
        selectedCount={selectedTraces.size}
        modelName="trace"
      >
        <Thead>
          <Tr>
            <Th />
            <Th>{__('Application')}</Th>
            <Th>{__('Type')}</Th>
            <Th>{__('Helper')}</Th>
          </Tr>
        </Thead>
        <Tbody>
          {results?.map((result, rowIndex) => {
          const {
            id,
            application,
            helper,
            app_type: appType,
          } = result;
          return (
            <Tr key={id} >
              <Td select={{
                disable: false,
                props: {
                  'aria-label': `check-${application}`,
                },
                isSelected: selectedTraces.has(id),
                onSelect: (event, isSelected) => onRowSelect({ isSelected, traceId: id }),
                rowIndex,
                variant: 'checkbox',
              }}
              />
              <Td>{application}</Td>
              <Td>{appType}</Td>
              <Td>{helper}</Td>
            </Tr>
          );
         })
         }
        </Tbody>
      </TableWrapper>
    </div>
  );
};
/* eslint-enable max-len */
export default TracesTab;
