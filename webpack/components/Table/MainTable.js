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
  children, showPrimaryAction, showSecondaryAction, primaryActionLink,
  secondaryActionLink, primaryActionTitle, secondaryActionTitle, resetFilters,
  updateSearchQuery, requestKey,
  ...extraTableProps
}) => {
  const tableHasNoRows = () => {
    if (children) return rowsCount === 0;
    return rows.length === 0;
  };
  const callToActionProps = {
    showPrimaryAction,
    showSecondaryAction,
    primaryActionLink,
    primaryActionTitle,
    secondaryActionLink,
    secondaryActionTitle,
  };
  const filtersAreActive = activeFilters?.length &&
    !isEqual(new Set(activeFilters), new Set(defaultFilters));
  const isFiltering = searchIsActive || filtersAreActive;
  if (status === STATUS.PENDING) return (<Loading />);
  const clearSearchProps = {
    resetFilters,
    searchIsActive,
    updateSearchQuery,
    filtersAreActive,
    requestKey,
  };
  // Can we display the error message?
  if (status === STATUS.ERROR) return (<EmptyStateMessage error={error} />);

  // scoped_search errors come back as 200 with an error message,
  // so they should be passed here as errorSearchBody & errorSearchTitle.
  if (status === STATUS.RESOLVED && !!errorSearchBody) {
    return (<EmptyStateMessage
      title={errorSearchTitle}
      body={errorSearchBody}
      search
    />);
  }
  if (status === STATUS.RESOLVED && isFiltering && tableHasNoRows()) {
    return (<EmptyStateMessage
      title={emptySearchTitle}
      body={emptySearchBody}
      search
      {...clearSearchProps}
    />);
  }
  if (status === STATUS.RESOLVED && tableHasNoRows()) {
    return (
      <EmptyStateMessage
        title={emptyContentTitle}
        body={emptyContentBody}
        happy={happyEmptyContent}
        search={!happyEmptyContent}
        {...callToActionProps}
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
    PropTypes.shape({}),
    PropTypes.string])),
  rows: PropTypes.arrayOf(PropTypes.shape({})),
  error: PropTypes.oneOfType([
    PropTypes.shape({}),
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
  showPrimaryAction: PropTypes.bool,
  showSecondaryAction: PropTypes.bool,
  primaryActionLink: PropTypes.string,
  secondaryActionLink: PropTypes.string,
  secondaryActionTitle: PropTypes.string,
  primaryActionTitle: PropTypes.string,
  resetFilters: PropTypes.func,
  updateSearchQuery: PropTypes.func,
  requestKey: PropTypes.string,
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
  showPrimaryAction: false,
  showSecondaryAction: false,
  primaryActionLink: '',
  secondaryActionLink: '',
  primaryActionTitle: '',
  secondaryActionTitle: '',
  resetFilters: undefined,
  updateSearchQuery: undefined,
  requestKey: '',
};

export default MainTable;
