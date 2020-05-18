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
      if (!loadingResponse && results && results.length > 0) {
        const { updatedRowMapping, ...tableData } = tableDataGenerator(
          results,
          rowMapping,
        );
        setTable(tableData);
        setRowMapping(updatedRowMapping);
      }
    },
    [results, JSON.stringify(rowMapping)], // use JSON to check obj values eq not reference eq
  );

  const cvIdFromRow = (rowIdx) => {
    const entry = Object.entries(rowMapping).find(item => item[1].rowIndex === rowIdx);
    if (entry) return parseInt(entry[0], 10);
    return null;
  };

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
    const contentViewId = cvIdFromRow(rowIndex);
    // adjust for the selection checkbox cell being counted in the index
    const adjustedColIndex = colIndex - 1;

    if (!isOpen) {
      setRowMapping((prev) => {
        const updatedMap = { ...prev[contentViewId], expandedColumn: adjustedColIndex };
        return { ...prev, [contentViewId]: updatedMap };
      });
    } else {
      setRowMapping(prev => ({ ...prev, [contentViewId]: {} }));
    }

    setTable(prevTable => ({ ...prevTable, rows }));
  };

  // Prevents flash of "No Content" before rows are loaded
  const tableStatus = () => {
    const resultsLength = results && results.length;
    const rowMappingLength = Object.keys(rowMapping) && Object.keys(rowMapping).length;
    if (resultsLength > rowMappingLength) return STATUS.PENDING;
    return status;
  };

  const emptyTitle = __("You currently don't have any Content Views.");
  const emptyBody = __('A Content View can be added by using the "New content view" button below.');

  const { rows, columns } = table;
  return (
    <TableWrapper
      {...{
        rows,
        error,
        metadata,
        emptyTitle,
        emptyBody,
        onSelect,
        onExpand,
        actionResolver,
      }}
      status={tableStatus()}
      fetchItems={getContentViews}
      canSelectAll={false}
      cells={columns}
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
