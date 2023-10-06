import React, { useState, useCallback } from 'react';
import { useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Thead, Tbody, Th, Tr, Td } from '@patternfly/react-table';
import getSmartProxyContent from './SmartProxyContentActions';
import {
  selectSmartProxyContent,
  selectSmartProxyContentStatus,
  selectSmartProxyContentError,
} from './SmartProxyContentSelectors';
import { useSet } from '../../components/Table/TableHooks';
import TableWrapper from '../../components/Table/TableWrapper';
import ExpandableCvDetails from './ExpandableCvDetails';

const SmartProxyExpandableTable = ({ smartProxyId }) => {
  const response = useSelector(selectSmartProxyContent);
  const status = useSelector(selectSmartProxyContentStatus);
  const error = useSelector(selectSmartProxyContentError);
  const [searchQuery, updateSearchQuery] = useState('');
  const expandedTableRows = useSet([]);
  const tableRowIsExpanded = id => expandedTableRows.has(id);
  let metadata = {};
  const {
    lifecycle_environments: results,
  } = response;
  if (results) {
    metadata = { total: results.length, subtotal: results.length };
  }
  const columnHeaders = [
    __('Environment'),
  ];
  const fetchItems = useCallback(() => getSmartProxyContent({ smartProxyId }), [smartProxyId]);

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
        </Tr>
      </Thead>
      {
        results?.map((env, rowIndex) => {
          const {
            name, id, content_views: contentViews, counts,
          } = env;
          const isExpanded = tableRowIsExpanded(id);
          return (
            <Tbody isExpanded={isExpanded} key={id}>
              <Tr key={id} ouiaId={`EnvRow-${id}`}>
                <Td
                  expand={{
                    rowIndex,
                    isExpanded,
                    onToggle: (_event, _rInx, isOpen) =>
                      expandedTableRows.onToggle(isOpen, id),
                  }}
                />
                <Td>{name}</Td>
              </Tr>
              <Tr key="child_row" ouiaId={`ContentViewTableRowChild-${id}`} isExpanded={isExpanded}>
                <Td colSpan={2}>
                  <ExpandableCvDetails contentViews={contentViews} counts={counts} />
                </Td>
              </Tr>
            </Tbody>
          );
        })
      }
    </TableWrapper >
  );
};

SmartProxyExpandableTable.propTypes = {
  smartProxyId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string, // The API can sometimes return strings
  ]).isRequired,
};

export default SmartProxyExpandableTable;
