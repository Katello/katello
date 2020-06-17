import React, { Fragment } from 'react';
import { Switch } from '@patternfly/react-core';
import { noop } from 'foremanReact/common/helpers';
import PropTypes from 'prop-types';

const EditableCheckbox = ({
  value, label, onEdit, editable,
}) => {
  const boolToYesNo = v => (v ? 'Yes' : 'No');
  const identifier = `checkbox-${label}`;

  return (
    <Fragment>
      {editable ?
        <Switch
          id={identifier}
          aria-label={identifier}
          isChecked={value}
          onChange={v => onEdit(v)}
        /> :
      boolToYesNo(value)
    }
    </Fragment>
  );
};

EditableCheckbox.propTypes = {
  value: PropTypes.bool.isRequired,
  label: PropTypes.string,
  onEdit: PropTypes.func,
  editable: PropTypes.bool,
};

EditableCheckbox.defaultProps = {
  label: '',
  onEdit: noop,
  editable: false,
};

export default EditableCheckbox;
