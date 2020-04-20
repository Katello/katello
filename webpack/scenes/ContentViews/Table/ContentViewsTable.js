import React, { useState, useEffect } from 'react';
import {
  Table,
  TableHeader,
  TableBody,
} from '@patternfly/react-table';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import Loading from './Loading';
import EmptyStateMessage from '../components/EmptyStateMessage';
import tableDataGenerator from './tableDataGenerator';
import './ContentViewsTable.scss';

const ContentViewTable = ({
  loadContentViewDetails, detailsMap, results, loading,
}) => {
  const [table, setTable] = useState({ rows: [], columns: [] });
  // Map of CV id to expanded cell, if id not present, row is not expanded
  const [expandedColumnMap, setExpandedColumnMap] = useState({});
  const cvsPresent = results && results.length > 0;

  useEffect(
    () => {
      if (!loading && cvsPresent) {
        const tableData = tableDataGenerator(
          results,
          detailsMap,
          expandedColumnMap,
        );
        setTable(tableData);
      }
    },
    [results, detailsMap, expandedColumnMap],
  );

  const cvIdFromRow = ({ details: { props: rowProps } }) => rowProps.contentviewid;

  const loadDetails = (id) => {
    if (detailsMap[id]) return;
    loadContentViewDetails(id);
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

  const onExpand = (_event, _rowIndex, colIndex, isOpen, rowData) => {
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

  const EmptyTitle = __("You currently don't have any Content Views.");
  const EmptyBody = __('A Content View can be added by using the "New content view" button below.');

  if (loading) return (<Loading />);
  if (!cvsPresent) return (<EmptyStateMessage title={EmptyTitle} body={EmptyBody} />);

  const { rows, columns } = table;
  return (
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
  );
};

ContentViewTable.propTypes = {
  loadContentViewDetails: PropTypes.func.isRequired,
  results: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  loading: PropTypes.bool.isRequired,
  detailsMap: PropTypes.shape({}).isRequired,
};

export default ContentViewTable;
