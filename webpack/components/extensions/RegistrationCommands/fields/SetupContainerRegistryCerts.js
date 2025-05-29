import React from 'react';
import PropTypes from 'prop-types';
import { noop } from 'foremanReact/common/helpers';

import { FormGroup, Checkbox } from '@patternfly/react-core';
import LabelIcon from 'foremanReact/components/common/LabelIcon';
import { translate as __ } from 'foremanReact/common/I18n';

const SetupContainerRegistryCerts = ({ value, onChange, isLoading }) => (
  <FormGroup fieldId="reg_container_certs">
    <Checkbox
      ouiaId="reg-container-certs"
      label={
        <span>
          {__('Set up container registry certs')}{' '}
          <LabelIcon text={__('Place symlinks to entitlement certificates on the host, enabling container/flatpak registry access without a username or password.')} />
        </span>
            }
      id="reg_container_certs"
      onChange={() => onChange({ setupContainerRegistryCerts: !value })}
      isDisabled={isLoading}
      isChecked={value}
    />
  </FormGroup>
);

SetupContainerRegistryCerts.propTypes = {
  value: PropTypes.bool,
  onChange: PropTypes.func,
  isLoading: PropTypes.bool,
};

SetupContainerRegistryCerts.defaultProps = {
  value: false,
  onChange: noop,
  isLoading: false,
};

export default SetupContainerRegistryCerts;
