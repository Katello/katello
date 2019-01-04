import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { FormGroup, ControlLabel } from '@theforeman/vendor/react-bootstrap';
import BootstrapSelect from '../../move_to_pf/react-bootstrap-select';

function MultiSelect(props) {
  const {
    options,
    onChange,
    defaultValues,
    ...otherProps
  } = props;

  const optionComponents = options.map(option => (
    <option key={`option-${option.value}`} value={option.value}>
      {option.label}
    </option>
  ));

  return (
    <FormGroup controlId="formControlsSelectMultiple">
      <ControlLabel srOnly>{__('Select Value')}</ControlLabel>
      <BootstrapSelect
        defaultValues={defaultValues}
        {...otherProps}
        multiple
        onChange={evt => onChange(evt)}
      >
        {optionComponents}
      </BootstrapSelect>
    </FormGroup>
  );
}

MultiSelect.defaultProps = {
  onChange: () => {},
  defaultValues: null,
};

MultiSelect.propTypes = {
  options: PropTypes.arrayOf(PropTypes.object).isRequired,
  onChange: PropTypes.func,
  defaultValues: PropTypes.arrayOf(PropTypes.string),
};

export default MultiSelect;
