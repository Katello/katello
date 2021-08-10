import React from 'react';
import {
  Table,
  TableHeader,
  TableBody,
  TableComposable,
} from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';

import EmptyStateMessage from './EmptyStateMessage';
import Loading from '../../components/Loading';

const MainTable = ({
  status, cells, rows, error, emptyContentTitle, emptyContentBody,
  emptySearchTitle, emptySearchBody, searchIsActive, activeFilters,
  composable, rowsCount, children, ...extraTableProps
}) => {
  if (!composable && (!cells || !rows)) {
    console.error(__('The <MainTable> component requires either a composable prop, or cells & rows props.')); // eslint-disable-line no-console
  }

  const tableHasNoRows = () => {
    if (composable) return rowsCount === 0;
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
  if (composable) {
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
    PropTypes.shape({}),
    PropTypes.string])),
  rows: PropTypes.arrayOf(PropTypes.shape({})),
  error: PropTypes.oneOfType([
    PropTypes.shape({}),
    PropTypes.string,
  ]),
  emptyContentTitle: PropTypes.string.isRequired,
  emptyContentBody: PropTypes.string.isRequired,
  emptySearchTitle: PropTypes.string.isRequired,
  emptySearchBody: PropTypes.string.isRequired,
  searchIsActive: PropTypes.bool,
  activeFilters: PropTypes.bool,
  composable: PropTypes.bool,
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
  composable: false,
  children: null,
  cells: undefined,
  rows: undefined,
  rowsCount: undefined,
};

export default MainTable;
