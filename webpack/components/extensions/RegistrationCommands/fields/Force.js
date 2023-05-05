import React from 'react';
import PropTypes from 'prop-types';
import { noop } from 'foremanReact/common/helpers';

import { FormGroup, Checkbox } from '@patternfly/react-core';
import LabelIcon from 'foremanReact/components/common/LabelIcon';
import { translate as __ } from 'foremanReact/common/I18n';

const Force = ({ value, onChange, isLoading }) => (
  <FormGroup fieldId="reg_katello_force">
    <Checkbox
      ouiaId="reg-katello-force"
      label={
        <span>
          {__('Force')}{' '}
          <LabelIcon text={__('Remove any `katello-ca-consumer` rpms before registration and run subscription-manager with `--force` argument.')} />
        </span>
      }
      id="reg_katello_force"
      onChange={() => onChange({ force: !value })}
      isDisabled={isLoading}
      isChecked={value}
    />
  </FormGroup>
);

Force.propTypes = {
  value: PropTypes.bool,
  onChange: PropTypes.func,
  isLoading: PropTypes.bool,
};

Force.defaultProps = {
  value: false,
  onChange: noop,
  isLoading: false,
};

export default Force;
