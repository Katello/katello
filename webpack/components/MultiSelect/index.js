import React from 'react';
import PropTypes from 'prop-types';

import { FormGroup, ControlLabel } from 'react-bootstrap';
import BootstrapSelect from '../../react-bootstrap-select/index';

function MultiSelect(props) {
  const options = props.options.map(option => (
    <option key={`option-${option.value}`} value={option.value}>
      {option.label}
    </option>
  ));

  return (
    <FormGroup controlId="formControlsSelectMultiple">
      <ControlLabel srOnly>{__('Select Value')}</ControlLabel>
      <BootstrapSelect multiple>{options}</BootstrapSelect>
    </FormGroup>
  );
}

MultiSelect.propTypes = {
  options: PropTypes.arrayOf(PropTypes.object).isRequired,
};

export default MultiSelect;
