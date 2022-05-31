import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Table,
  TableHeader,
  TableBody,
  TableComposable,
} from '@patternfly/react-table';
import { STATUS } from 'foremanReact/constants';
import { isEqual } from 'lodash';
import PropTypes from 'prop-types';
import './MainTable.scss';

import EmptyStateMessage from './EmptyStateMessage';
import Loading from '../../components/Loading';

const MainTable = ({
  status, cells, rows, error, emptyContentTitle, emptyContentBody,
  emptySearchTitle, emptySearchBody, errorSearchTitle, errorSearchBody,
  happyEmptyContent, searchIsActive, activeFilters, defaultFilters, actionButtons, rowsCount,
  children, ...extraTableProps
}) => {
  const tableHasNoRows = () => {
    if (children) return rowsCount === 0;
    return rows.length === 0;
  };
  const filtersAreActive = activeFilters?.length &&
    !isEqual(new Set(activeFilters), new Set(defaultFilters));
  const isFiltering = searchIsActive || filtersAreActive;
  if (status === STATUS.PENDING) return (<Loading />);
  console.log("Main table");
  console.log(status, errorSearchBody, isFiltering, tableHasNoRows());
  // Can we display the error message?
  if (status === STATUS.ERROR) return (<EmptyStateMessage error={error} />);

  // scoped_search errors come back as 200 with an error message,
  // so they should be passed here as errorSearchBody & errorSearchTitle.
  if (status === STATUS.RESOLVED && !!errorSearchBody) {
    console.log("status === STATUS.RESOLVED && !!errorSearchBody")
    return (<EmptyStateMessage
      title={errorSearchTitle}
      body={errorSearchBody}
      search
    />);
  }
  if (status === STATUS.RESOLVED && isFiltering && tableHasNoRows()) {
    console.log("status === STATUS.RESOLVED && isFiltering && tableHasNoRows()")
    return (<EmptyStateMessage
      title={emptySearchTitle}
      body={emptySearchBody}
      search
    />);
  }
  if (status === STATUS.RESOLVED && tableHasNoRows()) {
    console.log("status === STATUS.RESOLVED && tableHasNoRows()")
    console.log(happyEmptyContent, !happyEmptyContent)
    return (
      <EmptyStateMessage
        title={emptyContentTitle}
        body={emptyContentBody}
        happy={happyEmptyContent}
        search={!happyEmptyContent}
      />
    );
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
  emptyContentBody: PropTypes.oneOfType([PropTypes.string, PropTypes.shape({})]).isRequired,
  emptySearchTitle: PropTypes.string.isRequired,
  emptySearchBody: PropTypes.string.isRequired,
  errorSearchTitle: PropTypes.string,
  errorSearchBody: PropTypes.string,
  searchIsActive: PropTypes.bool,
  activeFilters: PropTypes.arrayOf(PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.arrayOf(PropTypes.string),
  ])),
  defaultFilters: PropTypes.arrayOf(PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.arrayOf(PropTypes.string),
  ])),
  actionButtons: PropTypes.bool,
  rowsCount: PropTypes.number,
  children: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.node),
    PropTypes.node,
  ]),
  happyEmptyContent: PropTypes.bool,
};

MainTable.defaultProps = {
  error: null,
  searchIsActive: false,
  activeFilters: [],
  defaultFilters: [],
  errorSearchTitle: __('Problem searching'),
  errorSearchBody: '',
  actionButtons: false,
  children: null,
  cells: undefined,
  rows: undefined,
  rowsCount: undefined,
  happyEmptyContent: false,
};

export default MainTable;
