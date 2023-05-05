import React from 'react';
import PropTypes from 'prop-types';
import { noop } from 'foremanReact/common/helpers';

import { FormGroup, Checkbox } from '@patternfly/react-core';
import LabelIcon from 'foremanReact/components/common/LabelIcon';
import { translate as __ } from 'foremanReact/common/I18n';

const IgnoreSubmanErrors = ({ value, onChange, isLoading }) => (
  <FormGroup fieldId="reg_katello_ignore">
    <Checkbox
      ouiaId="reg-katello-ignore"
      label={
        <span>
          {__('Ignore errors')}{' '}
          <LabelIcon text={__('Ignore subscription manager errors')} />
        </span>
      }
      id="reg_katello_ignore"
      onChange={() => onChange({ ignoreSubmanErrors: !value })}
      isDisabled={isLoading}
      isChecked={value}
    />
  </FormGroup>
);

IgnoreSubmanErrors.propTypes = {
  value: PropTypes.bool,
  onChange: PropTypes.func,
  isLoading: PropTypes.bool,
};

IgnoreSubmanErrors.defaultProps = {
  value: false,
  onChange: noop,
  isLoading: false,
};

export default IgnoreSubmanErrors;
