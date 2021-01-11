import React from 'react';
import PropTypes from 'prop-types';

import {
  FormGroup,
  FormSelectOption, FormSelect,
} from '@patternfly/react-core';

import { sprintf, translate as __ } from 'foremanReact/common/I18n';
import { noop } from 'foremanReact/common/helpers';

const LifeCycleEnvironment = ({
  pluginValues, onChange, isLoading,
  hostGroupEnvironment, lifeCycleEnvironments,
}) => (
  <FormGroup
    label={__('Lifecycle enviroment')}
    fieldId="reg_katello_lce"
    helperText={hostGroupEnvironment && sprintf('From host group: %s', hostGroupEnvironment)}
  >
    <FormSelect
      value={pluginValues?.lifecycleEnvironmentId}
      onChange={v => onChange({ lifecycleEnvironmentId: v })}
      className="without_select2"
      id="reg_katello_lce"
      isDisabled={isLoading || lifeCycleEnvironments.length === 0}
    >
      <FormSelectOption
        value=""
        label={lifeCycleEnvironments.length === 0 ? __('No LCE to select') : ''}
      />
      {lifeCycleEnvironments.map(lce => (
        <FormSelectOption key={lce.id} value={lce.id} label={lce.name} />
        ))}
    </FormSelect>
  </FormGroup>
);

LifeCycleEnvironment.propTypes = {
  pluginValues: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  onChange: PropTypes.func,
  hostGroupEnvironment: PropTypes.string,
  lifeCycleEnvironments: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  isLoading: PropTypes.bool,
};

LifeCycleEnvironment.defaultProps = {
  onChange: noop,
  isLoading: false,
  hostGroupEnvironment: '',
  lifeCycleEnvironments: [],
  pluginValues: {},

};

export default LifeCycleEnvironment;
