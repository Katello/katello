import React from 'react';
import PropTypes from 'prop-types';

import { FormGroup, ControlLabel } from 'react-bootstrap';
import BootstrapSelect from '../../move_to_pf/react-bootstrap-select';

function MultiSelect(props) {
  const { options, onChange, ...otherProps } = props;

  const optionComponents = options.map(option => (
    <option key={`option-${option.value}`} value={option.value}>
      {option.label}
    </option>
  ));

  return (
    <FormGroup controlId="formControlsSelectMultiple">
      <ControlLabel srOnly>{__('Select Value')}</ControlLabel>
      <BootstrapSelect {...otherProps} multiple onChange={evt => onChange(evt)}>
        {optionComponents}
      </BootstrapSelect>
    </FormGroup>
  );
}

MultiSelect.defaultProps = {
  onChange: () => {},
};

MultiSelect.propTypes = {
  options: PropTypes.arrayOf(PropTypes.object).isRequired,
  onChange: PropTypes.func,
};

export default MultiSelect;
