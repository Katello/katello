import React from 'react';
import PropTypes from 'prop-types';
import { Table as PfTable } from 'patternfly-react';
import { noop } from 'foremanReact/common/helpers';
import EmptyState from 'foremanReact/components/common/EmptyState';
import Pagination from 'foremanReact/components/Pagination/PaginationWrapper';

import TableBody from './TableBody';

const Table = ({
  columns,
  rows,
  emptyState,
  bodyMessage,
  children,
  itemCount,
  pagination,
  onPaginationChange,
  rowKey,
  ...props
}) => {
  if (rows.length === 0 && bodyMessage === undefined) {
    return <EmptyState {...emptyState} />;
  }

  const shouldRenderPagination = itemCount && pagination;

  const body = children || [
    <PfTable.Header key="header" />,
    <TableBody key="body" columns={columns} rows={rows} message={bodyMessage} rowKey={rowKey} />,
  ];

  return (
    <div>
      <PfTable.PfProvider
        columns={columns}
        className="table-fixed"
        striped
        bordered
        hover
        {...props}
      >
        {body}
      </PfTable.PfProvider>
      {shouldRenderPagination && (
        <Pagination
          viewType="table"
          itemCount={itemCount}
          pagination={pagination}
          onChange={onPaginationChange}
        />
      )}
    </div>
  );
};

Table.propTypes = {
  columns: PropTypes.arrayOf(PropTypes.object).isRequired,
  rows: PropTypes.arrayOf(PropTypes.object).isRequired,
  emptyState: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  pagination: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  bodyMessage: PropTypes.node,
  children: PropTypes.node,
  itemCount: PropTypes.number,
  onPaginationChange: PropTypes.func,
  rowKey: PropTypes.string,
};

Table.defaultProps = {
  emptyState: undefined,
  pagination: undefined,
  bodyMessage: undefined,
  children: undefined,
  itemCount: undefined,
  rowKey: 'id',
  onPaginationChange: noop,
};

export default Table;
