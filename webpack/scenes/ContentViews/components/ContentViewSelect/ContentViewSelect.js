import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { Select, SelectVariant } from '@patternfly/react-core';
import PropTypes from 'prop-types';

const ContentViewSelect = ({
  headerText,
  children,
  onClear,
  ...pfSelectProps
}) => (
  <div style={{ marginTop: '1em' }}>
    <h3>{headerText}</h3>
    <Select
      variant={SelectVariant.typeahead}
      onClear={onClear}
      maxHeight="20rem"
      menuAppendTo="parent"
      ouiaId="select-content-view"
      id="selectCV"
      name="selectCV"
      aria-label="selectCV"
      {...pfSelectProps}
    >
      {children}
    </Select>
  </div>
);

ContentViewSelect.propTypes = {
  headerText: PropTypes.string,
  onClear: PropTypes.func.isRequired,
  children: PropTypes.node,
};

ContentViewSelect.defaultProps = {
  headerText: __('Select content view'),
  children: [],
};

export default ContentViewSelect;
