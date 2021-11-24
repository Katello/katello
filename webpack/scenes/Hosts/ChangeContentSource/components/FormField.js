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
  label, id, value, items, onChange, isLoading, contentHostsCount,
}) => (
  <GridItem span={7}>
    <FormGroup label={label} fieldId={id} isRequired>
      <FormSelect
        value={value}
        onChange={v => onChange(v)}
        className="without_select2"
        isDisabled={isLoading || items.length === 0 || contentHostsCount === 0}
        id={`${id}_select`}
        isRequired
      >
        <FormSelectOption key={0} value="" label={__('Select ...')} />
        { items.map(item => (
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
  items: PropTypes.arrayOf(PropTypes.object).isRequired,
  onChange: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
  contentHostsCount: PropTypes.number.isRequired,
};

export default FormField;
