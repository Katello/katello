import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import { Table } from '@theforeman/vendor/patternfly-react';
import { noop } from 'foremanReact/common/helpers';

const TableSelectionHeaderCell = ({
  id, label, checked, onChange, ...props
}) => (
  <Table.SelectionHeading aria-label={label}>
    <Table.Checkbox
      id={id}
      label={label}
      checked={checked}
      onChange={onChange}
      {...props}
    />
  </Table.SelectionHeading>
);

TableSelectionHeaderCell.propTypes = {
  id: PropTypes.string,
  label: PropTypes.string,
  checked: PropTypes.bool,
  onChange: PropTypes.func,
};

TableSelectionHeaderCell.defaultProps = {
  id: 'selectAll',
  label: '',
  checked: false,
  onChange: noop,
};

export default TableSelectionHeaderCell;
