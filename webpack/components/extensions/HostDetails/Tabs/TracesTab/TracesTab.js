import React, { useState, useCallback } from 'react';
import { FormattedMessage } from 'react-intl';
import {
  Skeleton, Split, SplitItem, ActionList, ActionListItem, Dropdown,
  DropdownItem, DropdownToggle, DropdownToggleAction,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { useSelector } from 'react-redux';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import TracesEnabler from './TracesEnabler';
import TableWrapper from '../../../../Table/TableWrapper';
import { useBulkSelect, useTableSort, useUrlParams } from '../../../../Table/TableHooks';
import { getHostTraces } from './HostTracesActions';
import { resolveTraces } from '../RemoteExecutionActions';
import { selectHostTracesStatus } from './HostTracesSelectors';
import { resolveTraceUrl } from '../customizedRexUrlHelpers';
import './TracesTab.scss';
import hostIdNotReady from '../../HostDetailsActions';
import SortableColumnHeaders from '../../../../Table/components/SortableColumnHeaders';
import { useRexJobPolling } from '../RemoteExecutionHooks';

const TracesTab = () => {
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const {
    id: hostId,
    name: hostname,
    content_facet_attributes: contentFacetAttributes,
  } = hostDetails;
  const showEnableTracer = (contentFacetAttributes?.katello_tracer_installed === false);
  const emptyContentTitle = __('No applications to restart');
  const emptyContentBody = (<FormattedMessage
    id="traces-happy-empty"
    values={{
      pkgLink: <a href="#/Content/packages?status=Upgradable">{__('installing or updating packages')}</a>,
    }}
    defaultMessage={__('Traces may be listed here after {pkgLink}.')}
  />);
  const emptySearchTitle = __('No matching traces found');
  const emptySearchBody = __('Try changing your search settings.');
  const errorSearchTitle = __('Problem searching traces');
  const columnHeaders = [
    __('Application'),
    __('Type'),
    __('Helper'),
  ];
  const COLUMNS_TO_SORT_PARAMS = {
    [columnHeaders[0]]: 'application',
    [columnHeaders[1]]: 'app_type',
    [columnHeaders[2]]: 'helper',
  };
  const {
    pfSortParams, apiSortParams,
    activeSortColumn, activeSortDirection,
  } = useTableSort({
    allColumns: columnHeaders,
    columnsToSortParams: COLUMNS_TO_SORT_PARAMS,
    initialSortColumnName: 'Application',
  });
  const { searchParam } = useUrlParams();
  const [isBulkActionOpen, setIsBulkActionOpen] = useState(false);
  const toggleBulkAction = () => setIsBulkActionOpen(prev => !prev);
  const response = useSelector(state => selectAPIResponse(state, 'HOST_TRACES'));
  const { results, ...meta } = response;
  const { error: errorSearchBody } = meta;
  const tracesSearchQuery = id => `id = ${id}`;
  const {
    selectOne, isSelected, searchQuery, selectedCount, isSelectable,
    updateSearchQuery, selectNone, fetchBulkParams, ...selectAll
  } = useBulkSelect({
    results,
    metadata: meta,
    isSelectable: result => !!result.restart_command,
    initialSearchQuery: searchParam || '',
  });

  const BulkRestartTracesAction = () => resolveTraces({
    hostname, search: fetchBulkParams(),
  });
  const {
    triggerJobStart: triggerBulkRestart, lastCompletedJob: lastCompletedBulkRestart,
    isPolling: isBulkRestartInProgress,
  } = useRexJobPolling(BulkRestartTracesAction);

  const restartTraceAction = id => resolveTraces({
    hostname,
    search: tracesSearchQuery(id),
  });

  const {
    triggerJobStart: triggerAppRestart, lastCompletedJob: lastCompletedAppRestart,
    isPolling: isAppRestartInProgress,
  } = useRexJobPolling(restartTraceAction);

  const actionInProgress = (isBulkRestartInProgress || isAppRestartInProgress);

  const fetchItems = useCallback(
    params =>
      (hostId ? getHostTraces(hostId, { ...apiSortParams, ...params }) : hostIdNotReady),
    [hostId, apiSortParams],
  );

  const onBulkRestartApp = () => {
    triggerBulkRestart();
    selectNone();
  };

  const onRestartApp = id => triggerAppRestart(id);

  const bulkCustomizedRexUrl = () => resolveTraceUrl({
    hostname, search: (selectedCount > 0) ? fetchBulkParams() : '',
  });

  const dropdownItems = [
    <DropdownItem isDisabled={selectedCount === 0} aria-label="bulk_rex" key="bulk_rex" component="button" onClick={onBulkRestartApp}>
      {__('Restart via remote execution')}
    </DropdownItem>,
    <DropdownItem isDisabled={selectedCount === 0} aria-label="bulk_rex_customized" key="bulk_rex_customized" component="a" href={bulkCustomizedRexUrl()}>
      {__('Restart via customized remote execution')}
    </DropdownItem>,
  ];

  const actionButtons = (
    <Split hasGutter>
      <SplitItem>
        <ActionList isIconList>
          <ActionListItem>
            <Dropdown
              aria-label="bulk_actions_dropdown"
              toggle={
                <DropdownToggle
                  aria-label="bulk_actions"
                  splitButtonItems={[
                    <DropdownToggleAction key="action" onClick={onBulkRestartApp}>
                      {__('Restart app')}
                    </DropdownToggleAction>,
                  ]}
                  isDisabled={selectedCount === 0}
                  splitButtonVariant="action"
                  toggleVariant="primary"
                  onToggle={toggleBulkAction}
                />
              }
              isOpen={isBulkActionOpen}
              dropdownItems={dropdownItems}
            />
          </ActionListItem>
        </ActionList>
      </SplitItem>
    </Split>

  );
  const status = useSelector(state => selectHostTracesStatus(state));
  if (showEnableTracer) return <TracesEnabler hostname={hostname} />;

  if (!hostId) return <Skeleton />;

  /* eslint-disable max-len */
  return (
    <div id="traces-tab">
      <h3>{__('Tracer helps administrators identify applications that need to be restarted after a system is patched.')}</h3>
      <TableWrapper
        {...{
          emptyContentTitle,
          emptyContentBody,
          emptySearchTitle,
          emptySearchBody,
          errorSearchTitle,
          errorSearchBody,
          status,
          searchQuery,
          updateSearchQuery,
          selectedCount,
          selectNone,
          fetchItems,
          actionButtons,
        }
        }
        happyEmptyContent
        ouiaId="host-traces-table"
        metadata={meta}
        bookmarkController="katello_host_tracers"
        autocompleteEndpoint={`/hosts/${hostId}/traces/auto_complete_search`}
        foremanApiAutoComplete
        rowsCount={results?.length}
        variant={TableVariant.compact}
        displaySelectAllCheckbox
        additionalListeners={[activeSortColumn, activeSortDirection,
          lastCompletedAppRestart, lastCompletedBulkRestart]}
        {...selectAll}
      >
        <Thead>
          <Tr>
            <Th key="select_checkbox" />
            <SortableColumnHeaders
              columnHeaders={columnHeaders}
              pfSortParams={pfSortParams}
              columnsToSortParams={COLUMNS_TO_SORT_PARAMS}
            />
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
            // if (actionInProgress) {
            //   return (
            //     <Tr>
            //       <Td key={id} colSpan={5}>
            //         <Skeleton />
            //       </Td>
            //     </Tr>
            //   );
            // }
            const resolveDisabled = !isSelectable(id);
            let disabledReason;
            if (resolveDisabled) disabledReason = __('Traces that require logout cannot be restarted remotely');
            if (actionInProgress) disabledReason = __('A remote execution job is in progress');
            let rowDropdownItems = [
              { title: 'Restart via remote execution', onClick: () => onRestartApp(id), isDisabled: actionInProgress },
              {
                component: 'a', href: resolveTraceUrl({ hostname, search: tracesSearchQuery(id) }), title: 'Restart via customized remote execution',
              },
            ];
            if (resolveDisabled) {
              rowDropdownItems = [
                { isDisabled: true, title: __('Traces that require logout cannot be restarted remotely') },
              ];
            }
            return (
              <Tr key={id} >
                <Td
                  select={{
                    disable: actionInProgress || resolveDisabled,
                    props: {
                      'aria-label': `check-${application}`,
                    },
                    isSelected: isSelected(id),
                    onSelect: (event, selected) => selectOne(selected, id),
                    rowIndex,
                    variant: 'checkbox',
                  }}
                  title={disabledReason}
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
