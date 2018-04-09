/* eslint-disable */
import { Table as PfTable, customHeaderFormattersDefinition } from 'patternfly-react';
import React from 'react';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';
import EmptyState from '../emptyState';
import PaginationRow from '../../../../components/PaginationRow/index';

export const selectionCellFormatter = PfTable.selectionCellFormatter;
export const selectionHeaderCellFormatter = PfTable.selectionHeaderCellFormatter;

export const headerFormat = value => <PfTable.Heading>{value}</PfTable.Heading>;
export const cellFormat = value => <PfTable.Cell>{value}</PfTable.Cell>;

export const ellipsisFormat = value => (
  <PfTable.Cell>
    <EllipsisWithTooltip>{value}</EllipsisWithTooltip>
  </PfTable.Cell>
);

export const TableBody = (props) => {
  const { columns, rows, message } = props;

  if (message !== undefined) {
    return (
      <tbody>
        <tr>
          <td colSpan={columns.length}>{message}</td>
        </tr>
      </tbody>
    );
  }

  return (
    <PfTable.Body
      rows={rows}
      rowKey={({ rowIndex }) => rowIndex}
    />
  );
};

export class Table extends React.Component {
  constructor(props) {
    super(props);

    this.customHeaderFormatters = customHeaderFormattersDefinition;
  }

  isEmpty() {
    return this.props.rows.length === 0 && this.props.bodyMessage === undefined;
  }


  render() {
    const { columns, rows, emptyState, bodyMessage, children, itemCount, pagination, onPaginationChange, ...otherProps } = this.props;

    let paginationComponent;
    if (itemCount && pagination) {
      paginationComponent = (
        <PaginationRow
          viewType="table"
          itemCount={itemCount}
          pagination={pagination}
          onChange={onPaginationChange}
        />
      );
    }

    if (this.isEmpty()) {
      return (<EmptyState {...emptyState} />);
    }

    const table = (children !== undefined)
      ? children
      : [
        <PfTable.Header />,
        <TableBody columns={columns} rows={rows} message={bodyMessage} rowKey="id" />,
      ];

    return (
      <div>
        <PfTable.PfProvider
          className="table-fixed"
          striped
          bordered
          hover
          columns={columns}
          {...otherProps}
        >
          {table}
        </PfTable.PfProvider>
        {paginationComponent}
      </div>
    );
  }
}
