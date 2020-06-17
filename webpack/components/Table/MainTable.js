import React from 'react';
import {
  Table,
  TableHeader,
  TableBody,
} from '@patternfly/react-table';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';

import EmptyStateMessage from './EmptyStateMessage';
import Loading from '../../components/Loading';

const MainTable = ({
  status, cells, rows, error, emptyContentTitle, emptyContentBody,
  emptySearchTitle, emptySearchBody, searchIsActive, ...extraTableProps
}) => {
  if (status === STATUS.PENDING) return (<Loading />);
  // Can we display the error message?
  if (status === STATUS.ERROR) return (<EmptyStateMessage error={error} />);
  if (status === STATUS.RESOLVED && searchIsActive && rows.length === 0) {
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
    PropTypes.shape({}),
    PropTypes.string])).isRequired,
  rows: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  error: PropTypes.oneOfType([
    PropTypes.shape({}),
    PropTypes.string,
  ]),
  emptyContentTitle: PropTypes.string.isRequired,
  emptyContentBody: PropTypes.string.isRequired,
  emptySearchTitle: PropTypes.string.isRequired,
  emptySearchBody: PropTypes.string.isRequired,
  searchIsActive: PropTypes.bool,
};

MainTable.defaultProps = {
  error: null,
  searchIsActive: false,
};

export default MainTable;
