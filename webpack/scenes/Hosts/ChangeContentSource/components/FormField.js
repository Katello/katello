import React from 'react';
import {
  FormGroup,
  FormSelect,
  FormSelectOption,
  GridItem,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';

const FormField = ({
  label, id, value, items, onChange, isDisabled,
}) => (
  <GridItem span={7}>
    <FormGroup label={label} fieldId={id} isRequired>
      <FormSelect
        value={value}
        onChange={v => onChange(v)}
        className="without_select2"
        isDisabled={isDisabled}
        id={`${id}_select`}
        isRequired
      >
        <FormSelectOption key={0} value="" label={__('Select ...')} />
        {items.map(item => (
          <FormSelectOption key={item.id} value={item.id} label={item.name} />
        ))}
      </FormSelect>
    </FormGroup>
  </GridItem>
);

FormField.propTypes = {
  label: PropTypes.string.isRequired,
  id: PropTypes.string.isRequired,
  value: PropTypes.string.isRequired,
  items: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  onChange: PropTypes.func.isRequired,
  isDisabled: PropTypes.bool.isRequired,
};

export default FormField;
