import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'patternfly-react';
import { translate as __ } from 'foremanReact/common/I18n';
import { noop } from 'foremanReact/common/helpers';

const TableSelectionCell = ({
  id, before, after, label, checked, hide, onChange, ...props
}) => (
  <Table.SelectionCell>
    {before}
    {!hide &&
    <Table.Checkbox
      id={id}
      label={label}
      checked={checked}
      onChange={onChange}
      {...props}
    />}
    {after}
  </Table.SelectionCell>
);

TableSelectionCell.propTypes = {
  id: PropTypes.string.isRequired,
  before: PropTypes.node,
  after: PropTypes.node,
  label: PropTypes.string,
  checked: PropTypes.bool,
  hide: PropTypes.bool,
  onChange: PropTypes.func,
};

TableSelectionCell.defaultProps = {
  before: null,
  after: null,
  label: __('Select row'),
  checked: false,
  hide: false,
  onChange: noop,
};

export default TableSelectionCell;
