import React, { useState, useCallback } from 'react';
import { Skeleton, Button, Split, SplitItem, ActionList, ActionListItem, Dropdown,
  DropdownItem, KebabToggle } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { useSelector, useDispatch } from 'react-redux';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import EnableTracerEmptyState from './EnableTracerEmptyState';
import TableWrapper from '../../../Table/TableWrapper';
import { useSelectionSet } from '../../../Table/TableHooks';
import { getHostTraces } from './HostTracesActions';
import { resolveTraces } from './RemoteExecutionActions';
import { selectHostTracesStatus } from './HostTracesSelectors';
import { resolveTraceUrl } from './customizedRexUrlHelpers';
import './TracesTab.scss';

const TracesTab = () => {
  const [searchQuery, updateSearchQuery] = useState('');
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const dispatch = useDispatch();
  const {
    id: hostId,
    name: hostname,
    content_facet_attributes: contentFacetAttributes,
  } = hostDetails;
  const showEnableTracer = (contentFacetAttributes?.katello_tracer_installed === false);
  const emptyContentTitle = __('This host currently does not have traces.');
  const emptyContentBody = __('Add traces by applying updates on this host.');
  const emptySearchTitle = __('No matching traces found');
  const emptySearchBody = __('Try changing your search settings.');
  const fetchItems = useCallback(
    params =>
      (hostId ? getHostTraces(hostId, params) : null),
    [hostId],
  );
  const [isBulkActionOpen, setIsBulkActionOpen] = useState(false);
  const toggleBulkAction = () => setIsBulkActionOpen(prev => !prev);
  const response = useSelector(state => selectAPIResponse(state, 'HOST_TRACES'));
  const { results, ...meta } = response;
  const {
    selectOne,
    isSelected,
    selectionSet: selectedTraces,
    ...selectAll
  } = useSelectionSet(results, meta);

  const onBulkRestartApp = (ids) => {
    dispatch(resolveTraces({ hostname, ids: [...ids].join(',') }));
    selectedTraces.clear();

    const params = { page: meta.page, per_page: meta.per_page, search: meta.search };
    dispatch(getHostTraces(hostId, params));
  };

  const bulkCustomizedRexUrl = ids => resolveTraceUrl({ hostname, ids: [...ids] });

  const onRestartApp = id => onBulkRestartApp([id]);

  const selectPage = () => { // overriding selectPage so that you can't select session-type traces
    const ids = results.filter(result => !!result.restart_command).map(res => res.id);
    selectedTraces.addAll(ids);
  };

  const dropdownItems = [
    <DropdownItem isDisabled={!selectedTraces.size} aria-label="bulk_rex" key="bulk_rex" component="button" onClick={() => onBulkRestartApp(selectedTraces)}>
      {__('Restart via remote execution')}
    </DropdownItem>,
    <DropdownItem isDisabled={!selectedTraces.size} aria-label="bulk_rex_customized" key="bulk_rex_customized" component="a" href={bulkCustomizedRexUrl(selectedTraces)}>
      {__('Restart via customized remote execution')}
    </DropdownItem>,
  ];

  const actionButtons = (
    <Split hasGutter>
      <SplitItem>
        <ActionList isIconList>
          <ActionListItem>
            <Button
              variant="secondary"
              isDisabled={!selectedTraces.size}
              onClick={() => onBulkRestartApp(selectedTraces)}
            >
              {__('Restart app')}
            </Button>
          </ActionListItem>
          <ActionListItem>
            <Dropdown
              toggle={<KebabToggle aria-label="bulk_actions" onToggle={toggleBulkAction} />}
              isOpen={isBulkActionOpen}
              isPlain
              dropdownItems={dropdownItems}
            />
          </ActionListItem>
        </ActionList>
      </SplitItem>
    </Split>

  );
  const status = useSelector(state => selectHostTracesStatus(state));
  // const selectAll = () => {
  //   // leaving blank until we can implement selectAll Katello-wide
  // };
  if (showEnableTracer) return <EnableTracerEmptyState />;

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
        rowsCount={results?.length}
        variant={TableVariant.compact}
        status={status}
        metadata={meta}
        {...selectAll}
        selectPage={selectPage}
      >
        <Thead>
          <Tr>
            <Th key="select_checkbox" />
            <Th>{__('Application')}</Th>
            <Th>{__('Type')}</Th>
            <Th>{__('Helper')}</Th>
            <Th key="action_menu" />
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
          const resolveDisabled = (appType === 'session');
          let rowDropdownItems = [
            { title: 'Restart via remote execution', onClick: () => onRestartApp(id) },
            {
              component: 'a', href: resolveTraceUrl({ hostname, ids: [id] }), title: 'Restart via customized remote execution',
            },
          ];
          if (resolveDisabled) {
            rowDropdownItems = [
              { isDisabled: true, title: __('Traces that require logout cannot be restarted remotely') },
            ];
          }
          return (
            <Tr key={id} >
              <Td select={{
                disable: resolveDisabled,
                props: {
                  'aria-label': `check-${application}`,
                },
                isSelected: isSelected(id),
                onSelect: (event, selected) => selectOne(selected, id),
                rowIndex,
                variant: 'checkbox',
              }}
              />
              <Td>{application}</Td>
              <Td>{appType}</Td>
              <Td>{helper}</Td>
              <Td
                actions={{
                  items: rowDropdownItems,
                }}
              />
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
