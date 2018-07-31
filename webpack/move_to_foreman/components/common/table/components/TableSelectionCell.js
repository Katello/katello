import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'patternfly-react';
import { noop } from 'foremanReact/common/helpers';

const TableSelectionCell = ({
  id, before, after, label, checked, onChange, ...props
}) => (
  <Table.SelectionCell>
    {before}
    <Table.Checkbox
      id={id}
      label={label}
      checked={checked}
      onChange={onChange}
      {...props}
    />
    {after}
  </Table.SelectionCell>
);

TableSelectionCell.propTypes = {
  id: PropTypes.string.isRequired,
  before: PropTypes.node,
  after: PropTypes.node,
  label: PropTypes.string,
  checked: PropTypes.bool,
  onChange: PropTypes.func,
};

TableSelectionCell.defaultProps = {
  before: null,
  after: null,
  label: __('Select row'),
  checked: false,
  onChange: noop,
};

export default TableSelectionCell;
