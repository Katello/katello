import React, { useState, useCallback } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Thead, Tbody, Th, Tr, Td } from '@patternfly/react-table';
import { useSet } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import getSmartProxyContent, { updateSmartProxyContentCounts } from './SmartProxyContentActions';
import {
  selectSmartProxyContent,
  selectSmartProxyContentStatus,
  selectSmartProxyContentError,
} from './SmartProxyContentSelectors';
import TableWrapper from '../../components/Table/TableWrapper';
import ExpandableCvDetails from './ExpandableCvDetails';
import ComponentEnvironments from '../ContentViews/Details/ComponentContentViews/ComponentEnvironments';
import LastSync from '../ContentViews/Details/Repositories/LastSync';

const SmartProxyExpandableTable = ({ smartProxyId, organizationId }) => {
  const response = useSelector(selectSmartProxyContent);
  const status = useSelector(selectSmartProxyContentStatus);
  const error = useSelector(selectSmartProxyContentError);
  const [searchQuery, updateSearchQuery] = useState('');
  const expandedTableRows = useSet([]);
  const tableRowIsExpanded = id => expandedTableRows.has(id);
  const dispatch = useDispatch();
  let metadata = {};
  const {
    lifecycle_environments: results, content_counts: contentCounts,
  } = response;
  if (results) {
    metadata = { total: results.length, subtotal: results.length };
  }
  const columnHeaders = [
    __('Environment'),
    __('Last sync'),
  ];

  const refreshCountAction = envId => ({
    title: __('Refresh counts'),
    onClick: () => {
      dispatch(updateSmartProxyContentCounts(smartProxyId, { environment_id: envId }));
    },
  });

  const fetchItems = useCallback(
    () => getSmartProxyContent({ smartProxyId, organizationId }),
    [smartProxyId, organizationId],
  );

  const emptyContentTitle = __('No content views yet');
  const emptyContentBody = __('You currently have no content views to display');
  const emptySearchTitle = __('No matching content views found');
  const emptySearchBody = __('Try changing your search settings.');
  const alwaysHideToolbar = true;
  const hidePagination = true;

  return (
    <TableWrapper
      {...{
        error,
        metadata,
        emptyContentTitle,
        emptyContentBody,
        emptySearchTitle,
        emptySearchBody,
        searchQuery,
        updateSearchQuery,
        fetchItems,
        alwaysHideToolbar,
        hidePagination,
      }}
      ouiaId="capsule-content-table"
      autocompleteEndpoint=""
      status={status}
    >
      <Thead>
        <Tr ouiaId="cvTableHeaderRow">
          <Th key="expand-carat" />
          {columnHeaders.map(col => (
            <Th
              key={col}
            >
              {col}
            </Th>
          ))}
          <Th key="action-menu" />
        </Tr>
      </Thead>
      {
          results?.map((env, rowIndex) => {
            const {
              id, content_views: contentViews, last_sync: lastSync,
            } = env;
            const isExpanded = tableRowIsExpanded(id);
            return (
              <Tbody isExpanded={isExpanded} key={id} id="smart_proxy_table">
                <Tr key={id} ouiaId={`EnvRow-${id}`}>
                  <Td
                    aria-label={`expand-env-${id}`}
                    style={{ paddingTop: 0 }}
                    expand={{
                      rowIndex,
                      isExpanded,
                      onToggle: (_event, _rInx, isOpen) =>
                        expandedTableRows.onToggle(isOpen, id),
                    }}
                  />
                  <Td><ComponentEnvironments environments={[env]} /></Td>
                  <Td><LastSync lastSync={lastSync} lastSyncWords={lastSync?.last_sync_words} emptyMessage="N/A" /></Td>
                  <Td
                    key={`rowActions-${id}`}
                    actions={{
                      items: [refreshCountAction(id)],
                    }}
                  />
                </Tr>
                <Tr key="child_row" ouiaId={`ContentViewTableRowChild-${id}`} isExpanded={isExpanded}>
                  <Td colSpan={4}>
                    {isExpanded ?
                      <ExpandableCvDetails
                        smartProxyId={smartProxyId}
                        contentViews={contentViews}
                        contentCounts={contentCounts}
                        envId={id}
                      /> :
                      <></>}
                  </Td>
                </Tr>
              </Tbody>
            );
          })
        }
    </TableWrapper>
  );
};

SmartProxyExpandableTable.propTypes = {
  smartProxyId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string, // The API can sometimes return strings
  ]).isRequired,
  organizationId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string, // The API can sometimes return strings
  ]),
};

SmartProxyExpandableTable.defaultProps = {
  organizationId: null,
};

export default SmartProxyExpandableTable;
