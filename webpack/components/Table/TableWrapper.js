import React, { useEffect, useState } from 'react';
import {
  Table,
  TableHeader,
  TableBody,
} from '@patternfly/react-table';
import {
  Pagination,
} from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import { useForemanSettings } from 'foremanReact/Root/Context/ForemanContext';

import EmptyStateMessage from './EmptyStateMessage';
import Loading from './Loading';

/* Patternfly 4 table wrapper */
const TableWrapper = ({
  status, cells, rows, error, emptyTitle, emptyBody, metadata, fetchItems, ...extraTableProps
}) => {
  const dispatch = useDispatch();
  const { foremanPerPage = 20 } = useForemanSettings();
  // setting pagination to local state so it doesn't disappear when page reloads
  const [perPage, setPerPage] = useState(foremanPerPage);
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);

  useEffect(() => {
    const { total: newTotal, page: newPage, per_page: newPerPage } = metadata;
    if (newTotal) setTotal(parseInt(newTotal, 10));
    if (newPage) setPage(parseInt(newPage, 10));
    if (newPerPage) setPerPage(parseInt(newPerPage, 10));
  }, [metadata]);

  const buildMainTable = () => {
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

  const onPaginationUpdate = (updatedPagination) => {
    dispatch(fetchItems({ per_page: perPage, page, ...updatedPagination }));
  };

  return (
    <React.Fragment>
      <Pagination
        itemCount={total}
        page={page}
        perPage={perPage}
        onSetPage={(_evt, updated) => onPaginationUpdate({ page: updated })}
        onPerPageSelect={(_evt, updated) => onPaginationUpdate({ per_page: updated })}
        variant="top"
      />
      {buildMainTable()}
    </React.Fragment>
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
  fetchItems: PropTypes.func.isRequired,
  metadata: PropTypes.shape({
    total: PropTypes.number,
    page: PropTypes.oneOfType([
      PropTypes.number,
      PropTypes.string, // The API can sometimes return strings
    ]),
    per_page: PropTypes.oneOfType([
      PropTypes.number,
      PropTypes.string,
    ]),
  }),
};

TableWrapper.defaultProps = {
  error: null,
  metadata: {},
};

export default TableWrapper;
