import React from 'react';
import {
  Table,
  TableHeader,
  TableBody,
  TableComposable,
} from '@patternfly/react-table';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';

import EmptyStateMessage from './EmptyStateMessage';
import Loading from '../../components/Loading';

const MainTable = ({
  status, cells, rows, error, emptyContentTitle, emptyContentBody,
  emptySearchTitle, emptySearchBody, searchIsActive, activeFilters,
  composableChildren, composable, ...extraTableProps
}) => {
  const isFiltering = activeFilters || searchIsActive;
  if (status === STATUS.PENDING) return (<Loading />);
  // Can we display the error message?
  if (status === STATUS.ERROR) return (<EmptyStateMessage error={error} />);
  if (status === STATUS.RESOLVED && isFiltering && rows.length === 0) {
    return (<EmptyStateMessage
      title={emptySearchTitle}
      body={emptySearchBody}
      search
    />);
  }
  if (status === STATUS.RESOLVED && rows.length === 0) {
    return (<EmptyStateMessage title={emptyContentTitle} body={emptyContentBody} />);
  }

  const tableProps = { cells, rows, ...extraTableProps };
  if (composable) {
    console.log(composable, composableChildren);
    return (
    <TableComposable
        aria-label="Content View Table"
        className="katello-pf4-table"
      >
        {composableChildren}
      </TableComposable>
    );
  };
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
  status: PropTypes.string,
  cells: PropTypes.arrayOf(PropTypes.oneOfType([
    PropTypes.shape({}),
    PropTypes.string])),
  rows: PropTypes.arrayOf(PropTypes.shape({})),
  error: PropTypes.oneOfType([
    PropTypes.shape({}),
    PropTypes.string,
  ]),
  emptyContentTitle: PropTypes.string,
  emptyContentBody: PropTypes.string,
  emptySearchTitle: PropTypes.string,
  emptySearchBody: PropTypes.string,
  searchIsActive: PropTypes.bool,
  activeFilters: PropTypes.bool,
};

MainTable.defaultProps = {
  error: null,
  searchIsActive: false,
  activeFilters: false,
};

export default MainTable;
