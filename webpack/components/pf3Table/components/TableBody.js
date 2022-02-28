import React from 'react';
import PropTypes from 'prop-types';
import { Table as PfTable } from 'patternfly-react';

import TableBodyMessage from './TableBodyMessage';

const TableBody = ({
  columns, rows, message, ...props
}) => {
  if (message) {
    return <TableBodyMessage colSpan={columns.length}>{message}</TableBodyMessage>;
  }

  return <PfTable.Body rows={rows} rowKey={({ rowIndex }) => rowIndex} {...props} />;
};

TableBody.propTypes = {
  columns: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  rows: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  message: PropTypes.string,
};

TableBody.defaultProps = {
  message: '',
};

export default TableBody;
