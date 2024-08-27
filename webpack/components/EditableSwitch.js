import React from 'react';
import { Switch } from '@patternfly/react-core';
import { noop } from 'foremanReact/common/helpers';
import PropTypes from 'prop-types';

const EditableSwitch = ({
  value, attribute, onEdit, disabled, setCurrentAttribute,
}) => {
  const identifier = `${attribute} switch`;
  const onSwitch = (val) => {
    if (setCurrentAttribute) setCurrentAttribute(attribute);
    onEdit(val, attribute);
  };

  return (
    <Switch
      id={identifier}
      aria-label={identifier}
      ouiaId={`switch-${identifier}`}
      isChecked={value}
      onChange={(_event, val) => onSwitch(val)}
      disabled={disabled}
    />
  );
};

EditableSwitch.propTypes = {
  value: PropTypes.bool.isRequired,
  attribute: PropTypes.string,
  onEdit: PropTypes.func,
  disabled: PropTypes.bool,
  setCurrentAttribute: PropTypes.func,
};

EditableSwitch.defaultProps = {
  attribute: '',
  onEdit: noop,
  disabled: false,
  setCurrentAttribute: undefined,
};

export default EditableSwitch;
