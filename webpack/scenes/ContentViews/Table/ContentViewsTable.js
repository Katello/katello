import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';

import TableWrapper from './TableWrapper';
import tableDataGenerator from './tableDataGenerator';
import actionResolver from './actionResolver';

const ContentViewTable = ({
  items, status, error,
}) => {
  const [table, setTable] = useState({ rows: [], columns: [] });
  const [rowMapping, setRowMapping] = useState({});
  const loading = status === STATUS.PENDING;

  useEffect(
    () => {
      if (!loading && items && items.length > 0) {
        const { updatedRowMapping, ...tableData } = tableDataGenerator(
          items,
          rowMapping,
        );
        setTable(tableData);
        setRowMapping(updatedRowMapping);
      }
    },
    [items, JSON.stringify(rowMapping)], // use JSON to check obj values eq not reference eq
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
      // remove the row completely by assigning it to a throwaway variable
      // eslint-disable-next-line camelcase, no-unused-vars
      const { [contentViewId]: _throwaway, ...newMap } = rowMapping;
      setRowMapping(newMap);
    }

    setTable(prevTable => ({ ...prevTable, rows }));
  };

  const emptyTitle = __("You currently don't have any Content Views.");
  const emptyBody = __('A Content View can be added by using the "New content view" button below.');

  const { rows, columns } = table;
  return (
    <TableWrapper
      rows={rows}
      cells={columns}
      status={status}
      emptyTitle={emptyTitle}
      emptyBody={emptyBody}
      onSelect={onSelect}
      canSelectAll={false}
      onExpand={onExpand}
      actionResolver={actionResolver}
      error={error}
    />
  );
};

ContentViewTable.propTypes = {
  items: PropTypes.arrayOf(PropTypes.shape({})),
  status: PropTypes.string.isRequired,
  error: PropTypes.oneOfType([
    PropTypes.shape({}),
    PropTypes.string,
  ]),
};

ContentViewTable.defaultProps = {
  error: null,
  items: [],
};

export default ContentViewTable;
