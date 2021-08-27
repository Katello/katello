import React from 'react';
import {
  Table,
  TableHeader,
  TableBody,
  TableComposable,
} from '@patternfly/react-table';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';
import './MainTable.scss';

import EmptyStateMessage from './EmptyStateMessage';
import Loading from '../../components/Loading';

const MainTable = ({
  status, cells, rows, error, emptyContentTitle, emptyContentBody,
  emptySearchTitle, emptySearchBody, searchIsActive, activeFilters,
  actionButtons, rowsCount, children, ...extraTableProps
}) => {
  const tableHasNoRows = () => {
    if (children) return rowsCount === 0;
    return rows.length === 0;
  };
  const isFiltering = activeFilters || searchIsActive;
  if (status === STATUS.PENDING) return (<Loading />);
  // Can we display the error message?
  if (status === STATUS.ERROR) return (<EmptyStateMessage error={error} />);
  if (status === STATUS.RESOLVED && isFiltering && tableHasNoRows()) {
    return (<EmptyStateMessage
      title={emptySearchTitle}
      body={emptySearchBody}
      search
    />);
  }
  if (status === STATUS.RESOLVED && tableHasNoRows()) {
    return (<EmptyStateMessage title={emptyContentTitle} body={emptyContentBody} />);
  }

  const tableProps = { cells, rows, ...extraTableProps };
  if (children) {
    return (
      <TableComposable
        aria-label="Content View Table"
        className="katello-pf4-table"
        {...extraTableProps}
      >
        {children}
      </TableComposable>
    );
  }
  return (
    <Table
      aria-label="Content View Table"
      className="katello-pf4-table"
      {...tableProps}
    >
      <TableHeader />
      <TableBody />
    </Table>
  );
};

MainTable.propTypes = {
  status: PropTypes.string.isRequired,
  cells: PropTypes.arrayOf(PropTypes.oneOfType([
    PropTypes.shape({ }),
    PropTypes.string])),
  rows: PropTypes.arrayOf(PropTypes.shape({ })),
  error: PropTypes.oneOfType([
    PropTypes.shape({ }),
    PropTypes.string,
  ]),
  emptyContentTitle: PropTypes.string.isRequired,
  emptyContentBody: PropTypes.string.isRequired,
  emptySearchTitle: PropTypes.string.isRequired,
  emptySearchBody: PropTypes.string.isRequired,
  searchIsActive: PropTypes.bool,
  activeFilters: PropTypes.bool,
  actionButtons: PropTypes.bool,
  rowsCount: PropTypes.number,
  children: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.node),
    PropTypes.node,
  ]),
};

MainTable.defaultProps = {
  error: null,
  searchIsActive: false,
  activeFilters: false,
  actionButtons: false,
  children: null,
  cells: undefined,
  rows: undefined,
  rowsCount: undefined,
};

export default MainTable;
