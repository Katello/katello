import React from 'react';
import {
  Table,
  TableHeader,
  TableBody,
} from '@patternfly/react-table';
import PropTypes from 'prop-types';
import { STATUS } from 'foremanReact/constants';

import EmptyStateMessage from '../components/EmptyStateMessage';
import Loading from '../components/Loading';

const TableWrapper = ({
  status, cells, rows, error, emptyTitle, emptyBody, ...extraTableProps
}) => {
  if (status === STATUS.PENDING) return (<Loading />);
  // Can we display the error message?
  if (status === STATUS.ERROR) return (<EmptyStateMessage error={error} />);
  // Can we prevent flash of empty row message while rows are loading with data?
  if (status === STATUS.RESOLVED && rows.length === 0) {
    return (<EmptyStateMessage title={emptyTitle} body={emptyBody} />);
  }

  const tableProps = { cells, rows, ...extraTableProps };
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

TableWrapper.propTypes = {
  status: PropTypes.string.isRequired,
  cells: PropTypes.arrayOf(PropTypes.oneOfType([
    PropTypes.shape({}),
    PropTypes.string])).isRequired,
  rows: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  error: PropTypes.oneOfType([
    PropTypes.shape({}),
    PropTypes.string,
  ]),
  emptyBody: PropTypes.string.isRequired,
  emptyTitle: PropTypes.string.isRequired,
};

TableWrapper.defaultProps = {
  error: null,
};

export default TableWrapper;
