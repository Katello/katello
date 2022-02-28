import React from 'react';
import PropTypes from 'prop-types';

const Select = ({
  placeholder, onChange, options, disabled, value,
}) => {
  const renderOptions = arr =>
    arr.map(({ name, id }) => (
      <option key={id} value={id}>
        {name}
      </option>
    ));

  return (
    <select
      disabled={disabled}
      className="form-control"
      value={value}
      onChange={onChange}
    >
      <option value="" disabled >{placeholder}</option>
      {renderOptions(options)}
    </select>
  );
};

export default Select;

Select.propTypes = {
  onChange: PropTypes.func.isRequired,
  options: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  disabled: PropTypes.bool,
  placeholder: PropTypes.string.isRequired,
  value: PropTypes.string,
};

Select.defaultProps = {
  disabled: false,
  value: '',
};
