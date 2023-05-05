import React from 'react';
import PropTypes from 'prop-types';

import {
  FormGroup,
  FormSelectOption, FormSelect,
} from '@patternfly/react-core';

import { sprintf, translate as __ } from 'foremanReact/common/I18n';
import { noop } from 'foremanReact/common/helpers';

const LifecycleEnvironment = ({
  pluginValues, onChange, isLoading,
  hostGroupEnvironment, lifecycleEnvironments,
}) => (
  <FormGroup
    label={__('Lifecycle environment')}
    fieldId="reg_katello_lce"
    helperText={hostGroupEnvironment && sprintf('From host group: %s', hostGroupEnvironment)}
  >
    <FormSelect
      ouiaId="reg-katello-lce"
      value={pluginValues?.lifecycleEnvironmentId}
      onChange={v => onChange({ lifecycleEnvironmentId: v })}
      className="without_select2"
      id="reg_katello_lce"
      isDisabled={isLoading || lifecycleEnvironments.length === 0}
    >
      <FormSelectOption
        value=""
        label={lifecycleEnvironments.length === 0 ? __('No Lifecycle environment to select') : ''}
      />
      {lifecycleEnvironments.map(lce => (
        <FormSelectOption key={lce.id} value={lce.id} label={lce.name} />
      ))}
    </FormSelect>
  </FormGroup>
);

LifecycleEnvironment.propTypes = {
  pluginValues: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  onChange: PropTypes.func,
  hostGroupEnvironment: PropTypes.string,
  lifecycleEnvironments: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  isLoading: PropTypes.bool,
};

LifecycleEnvironment.defaultProps = {
  onChange: noop,
  isLoading: false,
  hostGroupEnvironment: '',
  lifecycleEnvironments: [],
  pluginValues: {},

};

export default LifecycleEnvironment;
