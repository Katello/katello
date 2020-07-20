import React from 'react';
import { Switch } from '@patternfly/react-core';
import { noop } from 'foremanReact/common/helpers';
import PropTypes from 'prop-types';

const EditableSwitch = ({ value, attribute, onEdit }) => {
  const identifier = `${attribute} switch`;

  return (
    <Switch
      id={identifier}
      aria-label={identifier}
      isChecked={value}
      onChange={v => onEdit(v, attribute)}
    />
  );
};

EditableSwitch.propTypes = {
  value: PropTypes.bool.isRequired,
  attribute: PropTypes.string,
  onEdit: PropTypes.func,
};

EditableSwitch.defaultProps = {
  attribute: '',
  onEdit: noop,
};

export default EditableSwitch;
