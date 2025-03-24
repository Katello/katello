import React, { useState, useCallback } from 'react';
import { FormattedMessage } from 'react-intl';
import {
  Skeleton,
  Split,
  SplitItem,
  ActionList,
  ActionListItem,
  Alert,
} from '@patternfly/react-core';
import {
  Dropdown,
  DropdownItem,
  DropdownToggle,
  DropdownToggleAction,
} from '@patternfly/react-core/deprecated';
import { translate as __ } from 'foremanReact/common/I18n';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { ExclamationTriangleIcon } from '@patternfly/react-icons';
import { useSelector } from 'react-redux';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import { useBulkSelect, useUrlParams } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { useTableSort } from 'foremanReact/components/PF4/Helpers/useTableSort';
import TracesEnabler from './TracesEnabler';
import TableWrapper from '../../../../Table/TableWrapper';
import { getHostTraces } from './HostTracesActions';
import { resolveTraces } from '../RemoteExecutionActions';
import { selectHostTracesStatus } from './HostTracesSelectors';
import { resolveTraceUrl } from '../customizedRexUrlHelpers';
import './TracesTab.scss';
import hostIdNotReady from '../../HostDetailsActions';
import SortableColumnHeaders from '../../../../Table/components/SortableColumnHeaders';
import { useRexJobPolling } from '../RemoteExecutionHooks';
import { hasRequiredPermissions as can,
  missingRequiredPermissions as cannot,
  userPermissionsFromHostDetails } from '../../hostDetailsHelpers';
import { HOST_TRACES_KEY } from './HostTracesConstants';

const invokeRexJobs = ['create_job_invocations'];
const createBookmarks = ['create_bookmarks'];
const containsStaticType = (results = []) => results.some(result => result.app_type === 'static');

const TracesTab = () => {
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const {
    id: hostId,
    name: hostname,
    content_facet_attributes: contentFacetAttributes,
  } = hostDetails;
  const showActions = can(invokeRexJobs, userPermissionsFromHostDetails({ hostDetails }));
  const showEnableTracer = (contentFacetAttributes?.katello_tracer_installed === false);
  const tracerRpmAvailable = contentFacetAttributes?.katello_tracer_rpm_available;
  const emptyContentTitle = showActions ? __('No applications to restart') : __('Traces not available');
  const tracesNotAvailBody = showEnableTracer ? __('Traces may be enabled by a user with the appropriate permissions.') :
    __('Traces will be shown here to a user with the appropriate permissions.');
  const emptyContentBody = showActions ? (<FormattedMessage
    id="traces-happy-empty"
    values={{
      pkgLink: <a href="#/Content/packages?status=Upgradable">{__('installing or updating packages')}</a>,
    }}
    defaultMessage={__('Traces may be listed here after {pkgLink}.')}
  />) : tracesNotAvailBody;
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
    updateSearchQuery, selectNone, fetchBulkParams, selectedResults,
    selectAllMode, ...selectAll
  } = useBulkSelect({
    results,
    metadata: meta,
    isSelectable: result => !!result.restart_command,
    initialSearchQuery: searchParam || '',
  });
  const willRestartHost = containsStaticType(selectedResults)
    || (selectAllMode && containsStaticType(results));

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

  const readOnlyBookmarks =
  cannot(createBookmarks, userPermissionsFromHostDetails({ hostDetails }));

  const dropdownItems = [
    <DropdownItem
      isDisabled={selectedCount === 0}
      aria-label="bulk_rex"
      ouiaId="bulk_rex"
      key="bulk_rex"
      component="button"
      onClick={onBulkRestartApp}
    >
      {__('Restart via remote execution')}
    </DropdownItem>,
    <DropdownItem
      isDisabled={selectedCount === 0}
      aria-label="bulk_rex_customized"
      ouiaId="bulk_rex_customized"
      key="bulk_rex_customized"
      component="a"
      href={bulkCustomizedRexUrl()}
    >
      {__('Restart via customized remote execution')}
    </DropdownItem>,
  ];

  const actionButtons = showActions ? (
    <Split hasGutter>
      <SplitItem>
        <ActionList isIconList>
          <ActionListItem>
            <Dropdown
              aria-label="bulk_actions_dropdown"
              ouiaId="bulk_actions_dropdown"
              toggle={
                <DropdownToggle
                  aria-label="bulk_actions"
                  ouiaId="bulk_actions"
                  splitButtonItems={[
                    <DropdownToggleAction key="action" onClick={onBulkRestartApp}>
                      {willRestartHost ? __('Reboot host') : __('Restart app')}
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

  ) : null;
  const status = useSelector(state => selectHostTracesStatus(state));
  if (showEnableTracer && showActions) {
    return <TracesEnabler hostname={hostname} tracerRpmAvailable={tracerRpmAvailable} />;
  }

  if (!hostId) return <Skeleton />;

  /* eslint-disable max-len */
  return (
    <div id="traces-tab">
      <h3>{__('Tracer helps administrators identify applications that need to be restarted after a system is patched.')}</h3>
      {willRestartHost && (
      <Alert isInline variant="warning" ouiaId="host-will-reboot-alert" title={__('At least one of the selected items requires the host to reboot')} />
      )}
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
        happyEmptyContent={showActions}
        ouiaId="host-traces-table"
        metadata={meta}
        bookmarkController="katello_host_tracers"
        readOnlyBookmarks={readOnlyBookmarks}
        autocompleteEndpoint={`/api/v2/hosts/${hostId}/traces`}
        rowsCount={results?.length}
        variant={TableVariant.compact}
        additionalListeners={[activeSortColumn, activeSortDirection,
          lastCompletedAppRestart, lastCompletedBulkRestart]}
        displaySelectAllCheckbox={showActions}
        {...selectAll}
        requestKey={HOST_TRACES_KEY}
      >
        <Thead>
          <Tr ouiaId="row-header">
            <Th key="select_checkbox" aria-label="select table header" />
            <SortableColumnHeaders
              columnHeaders={columnHeaders}
              pfSortParams={pfSortParams}
              columnsToSortParams={COLUMNS_TO_SORT_PARAMS}
            />
            <Th key="action_menu" aria-label="action menu table header" />
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
            const resolveDisabled = !isSelectable(id);
            let disabledReason;
            if (resolveDisabled) disabledReason = __('Traces that require logout cannot be restarted remotely');
            if (actionInProgress) disabledReason = __('A remote execution job is in progress');
            let rowDropdownItems = [
              { title: 'Restart via remote execution', onClick: () => onRestartApp(id), isDisabled: actionInProgress },
              {
                title: <a href={resolveTraceUrl({ hostname, search: tracesSearchQuery(id) })}>{__('Restart via customized remote execution')}</a>,
              },
            ];
            if (resolveDisabled) {
              rowDropdownItems = [
                { isDisabled: true, title: __('Traces that require logout cannot be restarted remotely') },
              ];
            }
            return (
              <Tr key={id} ouiaId={`row-${id}`} >
                {showActions ? (
                  <Td
                    select={{
                      isDisabled: actionInProgress || resolveDisabled,
                      props: {
                        'aria-label': `check-${application}`,
                      },
                      isSelected: isSelected(id),
                      onSelect: (event, selected) => selectOne(selected, id, result),
                      rowIndex,
                      variant: 'checkbox',
                    }}
                    title={disabledReason}
                  />
                ) : <Td>&nbsp;</Td>
                }
                <Td>{application}</Td>
                <Td>{appType}</Td>
                <Td>{appType === 'static' ? <ExclamationTriangleIcon /> : null} {helper}</Td>
                {showActions && (
                  <Td
                    actions={{
                      items: rowDropdownItems,
                    }}
                  />
                )}
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
