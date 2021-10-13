import React, { useState, useCallback } from 'react';
import { Skeleton, Button, Alert } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { useSelector, useDispatch } from 'react-redux';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import EnableTracerEmptyState from './EnableTracerEmptyState';
import TableWrapper from '../../../Table/TableWrapper';
import { useSelectionSet } from '../../../Table/TableHooks';
import { getHostTraces, resolveHostTraces } from './HostTracesActions';
import { selectHostTracesStatus } from './HostTracesSelectors';
import './TracesTab.scss';

const TracesTab = () => {
  const [searchQuery, updateSearchQuery] = useState('');
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const dispatch = useDispatch();
  const { id: hostId, content_facet_attributes: contentFacetAttributes } = hostDetails;
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
  const response = useSelector(state => selectAPIResponse(state, 'HOST_TRACES'));
  const { results, ...meta } = response;
  const {
    selectOne, isSelected, selectionSet: selectedTraces, ...selectAll
  } = useSelectionSet(results, meta);

  const onRestartApp = () => {
    dispatch(resolveHostTraces(hostId, { trace_ids: [...selectedTraces] }));
    selectedTraces.clear();
    const params = { page: meta.page, per_page: meta.per_page, search: meta.search };
    dispatch(getHostTraces(hostId, params));
  };
  const actionButtons = (
    <Button
      variant="secondary"
      isDisabled={!selectedTraces.size}
      onClick={onRestartApp}
    >
      {__('Restart app')}
    </Button>
  );
  const status = useSelector(state => selectHostTracesStatus(state));
  // const selectAll = () => {
  //   // leaving blank until we can implement selectAll Katello-wide
  // };
  if (showEnableTracer) return <EnableTracerEmptyState />;

  if (!hostId) return <Skeleton />;

  /* eslint-disable max-len */
  return (
    <div>
      <div id="traces-alert">
        <Alert variant="info" isInline title={__('Note')}>
          {__('Traces functionality on this page is incomplete.')} {' '}
          <a href={urlBuilder(`content_hosts/${hostId}/traces`, '')}>{__('Visit the previous Traces page') }.</a>
        </Alert>
      </div>
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
                isSelected: isSelected(id),
                onSelect: (event, selected) => selectOne(selected, id),
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
    </div>
  );
};
/* eslint-enable max-len */
export default TracesTab;
