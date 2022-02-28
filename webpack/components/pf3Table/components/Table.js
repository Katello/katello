import React from 'react';
import PropTypes from 'prop-types';
import { Table as PfTable } from 'patternfly-react';
import { noop } from 'foremanReact/common/helpers';
import EmptyState from 'foremanReact/components/common/EmptyState';
import Pagination from 'foremanReact/components/Pagination';

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
  ...props
}) => {
  if (rows.length === 0 && bodyMessage === undefined) {
    return <EmptyState {...emptyState} />;
  }

  const shouldRenderPagination = itemCount && pagination;

  const body = children || [
    <PfTable.Header key="header" />,
    <TableBody key="body" columns={columns} rows={rows} message={bodyMessage} rowKey="id" />,
  ];

  return (
    <div>
      <PfTable.PfProvider
        columns={columns}
        className="table-fixed neat-table-cells"
        striped
        bordered
        hover
        {...props}
      >
        {body}
      </PfTable.PfProvider>
      {shouldRenderPagination && (
        <Pagination
          itemCount={itemCount}
          onChange={onPaginationChange}
          {...pagination}
        />
      )}
    </div>
  );
};

Table.propTypes = {
  columns: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  rows: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  emptyState: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  pagination: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  bodyMessage: PropTypes.node,
  children: PropTypes.node,
  itemCount: PropTypes.number,
  onPaginationChange: PropTypes.func,
};

Table.defaultProps = {
  emptyState: undefined,
  pagination: undefined,
  bodyMessage: undefined,
  children: undefined,
  itemCount: undefined,
  onPaginationChange: noop,
};

export default Table;
