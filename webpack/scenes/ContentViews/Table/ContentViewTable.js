import React, { useState, useEffect } from 'react';
import {
  Table,
  TableHeader,
  TableBody,
} from '@patternfly/react-table';
import PropTypes from 'prop-types';

import Loading from './Loading';
import tableDataGenerator, { buildColumns } from './tableDataGenerator';
import emptyRows from './emptyRows';
import './ContentViewTable.scss';

const contentViewShowFakeData = require('../data/show');

const ContentViewTable = ({ contentViews }) => {
  const [detailsMap, setDetailsMap] = useState({}); // Map of CV id to details object
  const [table, setTable] = useState({ rows: [], columns: [] });
  // Map of CV id to expanded cell, if id not present, row is not expanded
  const [expandedColumnMap, setExpandedColumnMap] = useState({});
  const cvsPresent = contentViews && contentViews.results && contentViews.results.length > 0;

  useEffect(
    () => {
      if (!contentViews) return;
      if (cvsPresent) {
        const tableData = tableDataGenerator(
          contentViews,
          detailsMap,
          expandedColumnMap,
        );
        setTable(tableData);
      } else {
        setTable({ columns: buildColumns(), rows: emptyRows });
      }
    },
    [contentViews, detailsMap, expandedColumnMap],
  );

  const cvIdFromRow = ({ details: { props: rowProps } }) => rowProps.contentviewid;

  const loadDetails = (id) => {
    if (detailsMap[id]) return;
    // Replace with API call
    setTimeout(() => {
      const details = contentViewShowFakeData;
      setDetailsMap(prev => ({ ...prev, [id]: details }));
    }, 300);
  };

  const onSelect = (event, isSelected, rowId) => {
    let rows;
    if (rowId === -1) {
      rows = table.rows.map((row) => {
        row.selected = isSelected;
        return row;
      });
    } else {
      rows = [...table.rows];
      rows[rowId].selected = isSelected;
    }

    setTable(prevTable => ({ ...prevTable, rows }));
  };

  const onExpand = (_event, _rowIndex, colIndex, isOpen, rowData, _extraData) => {
    const { rows } = table;
    const contentViewId = cvIdFromRow(rowData);
    // adjust for the selection checkbox cell being counted in the index
    const adjustedColIndex = colIndex - 1;

    if (!isOpen) {
      setExpandedColumnMap(prev => ({ ...prev, [contentViewId]: adjustedColIndex }));
    } else {
      // remove the row completely by assigning it to a throwaway variable
      // eslint-disable-next-line camelcase, no-unused-vars
      const { [contentViewId]: _throwaway, ...newMap } = expandedColumnMap;
      setExpandedColumnMap(newMap);
    }
    loadDetails(contentViewId);

    setTable(prevTable => ({ ...prevTable, rows }));
  };

  const actionResolver = (rowData, { _rowIndex }) => {
    // don't show actions for the expanded parts
    if (rowData.parent || rowData.compoundParent || rowData.noactions) return null;

    // printing to the console for now until these are hooked up
    /* eslint-disable no-console */
    return [
      {
        title: 'Publish and Promote',
        onClick: (_event, rowId, rowInfo) => console.log(`clicked on row ${rowId} with Content View ${cvIdFromRow(rowInfo)}`),
      },
      {
        title: 'Promote',
        onClick: (_event, rowId, rowInfo) => console.log(`clicked on row ${rowId} with Content View ${cvIdFromRow(rowInfo)}`),
      },
      {
        title: 'Copy',
        onClick: (_event, rowId, rowInfo) => console.log(`clicked on row ${rowId} with Content View ${cvIdFromRow(rowInfo)}`),
      },
      {
        title: 'Delete',
        onClick: (_event, rowId, rowInfo) => console.log(`clicked on row ${rowId} with Content View ${cvIdFromRow(rowInfo)}`),
      },
    ];
    /* eslint-enable no-console */
  };

  const { rows, columns } = table;
  return contentViews ?
    (
      <Table
        aria-label="Content View Table"
        onSelect={cvsPresent ? onSelect : null}
        onExpand={onExpand}
        className="katello-pf4-table"
        actionResolver={actionResolver}
        cells={columns}
        rows={rows}
      >
        <TableHeader />
        <TableBody />
      </Table>
    ) : (<Loading />);
};

ContentViewTable.propTypes = {
  contentViews: PropTypes.shape({
    results: PropTypes.array,
  }),
};

ContentViewTable.defaultProps = {
  contentViews: null,
};

export default ContentViewTable;
