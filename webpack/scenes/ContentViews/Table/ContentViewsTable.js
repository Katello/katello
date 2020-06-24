import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';

import TableWrapper from '../../../components/Table/TableWrapper';
import tableDataGenerator from './tableDataGenerator';
import actionResolver from './actionResolver';
import getContentViews from '../ContentViewsActions';

const ContentViewTable = ({ response, status, error }) => {
  const [table, setTable] = useState({ rows: [], columns: [] });
  const [rowMapping, setRowMapping] = useState({});
  const { results, ...metadata } = response;
  const loadingResponse = status === STATUS.PENDING;

  useEffect(
    () => {
      if (!loadingResponse && results) {
        const { updatedRowMap, ...tableData } = tableDataGenerator(
          results,
          rowMapping,
        );
        setTable(tableData);
        setRowMapping(updatedRowMap);
      }
    },
    [results, JSON.stringify(rowMapping)], // use JSON to check obj values eq not reference eq
  );

  const onSelect = (event, isSelected, rowId) => {
    let rows;
    if (rowId === -1) {
      rows = table.rows.map(row => ({ ...row, selected: isSelected }));
    } else {
      rows = [...table.rows];
      rows[rowId].selected = isSelected;
    }

    setTable(prevTable => ({ ...prevTable, rows }));
  };

  const onExpand = (_event, rowIndex, colIndex, isOpen) => {
    const { rows } = table;
    // adjust for the selection checkbox cell being counted in the index
    const adjustedColIndex = colIndex - 1;

    if (!isOpen) {
      setRowMapping((prev) => {
        const updatedMap = { ...prev[rowIndex], expandedColumn: adjustedColIndex };
        return { ...prev, [rowIndex]: updatedMap };
      });
    } else {
      // Keep id in object to not throw off tableStatus id checks
      setRowMapping(prev => ({ ...prev, [rowIndex]: { id: prev[rowIndex].id } }));
    }

    setTable(prevTable => ({ ...prevTable, rows }));
  };

  // Prevents flash of "No Content" before rows are loaded
  const tableStatus = () => {
    if (typeof results === 'undefined') return status; // will handle errored state
    const rowMappingIds = Object.values(rowMapping).map(row => row.id);
    const resultsIds = Array.from(results.map(result => result.id));
    // All results are accounted for in row mapping, the page is ready to load
    if (resultsIds.length === rowMappingIds.length &&
        resultsIds.every(id => rowMappingIds.includes(id))) {
      return status;
    }
    return STATUS.PENDING; // Fallback to pending
  };

  const emptyContentTitle = __("You currently don't have any Content Views.");
  const emptyContentBody = __('A content view can be added by using the "New content view" button below.');
  const emptySearchTitle = __('No matching content views found');
  const emptySearchBody = __('Try changing your search settings.');

  const { rows, columns } = table;
  return (
    <TableWrapper
      {...{
        rows,
        error,
        metadata,
        emptyContentTitle,
        emptyContentBody,
        emptySearchTitle,
        emptySearchBody,
        onSelect,
        onExpand,
        actionResolver,
      }}
      status={tableStatus()}
      fetchItems={getContentViews}
      canSelectAll={false}
      cells={columns}
      autocompleteEndpoint="/content_views/auto_complete_search"
    />
  );
};

ContentViewTable.propTypes = {
  response: PropTypes.shape({
    results: PropTypes.arrayOf(PropTypes.shape({})),
  }),
  status: PropTypes.string.isRequired,
  error: PropTypes.oneOfType([
    PropTypes.shape({}),
    PropTypes.string,
  ]),
};

ContentViewTable.defaultProps = {
  error: null,
  response: { results: [] },
};

export default ContentViewTable;
