/* eslint-disable */
import { Table as PfTable } from 'patternfly-react';
import React from 'react';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';
import EmptyState from '../emptyState';

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
  )
}

class Table extends React.Component {
  isEmpty() {
    return this.props.rows.length === 0 && this.props.bodyMessage === undefined;
  }

  render() {
    const { columns, rows, emptyState, bodyMessage } = this.props;
    return this.isEmpty() ? (
      <EmptyState {...emptyState} />
    ) : (
      <PfTable.PfProvider
        className="table-fixed"
        striped
        bordered
        hover
        columns={columns}
      >
        <PfTable.Header />
        <TableBody columns={columns} rows={rows} message={bodyMessage} />
      </PfTable.PfProvider>
    );
  }
}
export default Table;
