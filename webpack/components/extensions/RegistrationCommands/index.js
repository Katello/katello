import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { noop } from 'foremanReact/common/helpers';

import ActivationKeys from './fields/ActivationKeys';
import LifecycleEnvironment from './fields/LifecycleEnvironment';
import IgnoreSubmanErrors from './fields/IgnoreSubmanErrors';
import Force from './fields/Force';

export const RegistrationCommands = ({
  organizationId,
  hostGroupId,
  pluginValues,
  pluginData,
  onChange,
  isLoading,
}) => {
  useEffect(() => {
    onChange({ lifecycleEnvironmentId: '' });
  }, [onChange, organizationId, hostGroupId]);

  return (
    <>
      <LifecycleEnvironment
        pluginValues={pluginValues}
        lifecycleEnvironments={pluginData?.lifecycleEnvironments}
        hostGroupEnvironment={pluginData?.hostGroupEnvironment}
        organizationId={organizationId}
        onChange={onChange}
        isLoading={isLoading}
      />
      <IgnoreSubmanErrors
        value={pluginValues?.ignoreSubmanErrors}
        pluginValues={pluginValues}
        onChange={onChange}
        isLoading={isLoading}
      />
      <Force
        value={pluginValues?.force}
        pluginValues={pluginValues}
        onChange={onChange}
        isLoading={isLoading}
      />
    </>
  );
};

RegistrationCommands.propTypes = {
  organizationId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  hostGroupId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  pluginValues: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  pluginData: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  onChange: PropTypes.func,
  isLoading: PropTypes.bool,
};

RegistrationCommands.defaultProps = {
  organizationId: undefined,
  hostGroupId: undefined,
  pluginValues: {},
  pluginData: {},
  isLoading: false,
  onChange: noop,
};

export const RegistrationActivationKeys = ({
  organizationId,
  hostGroupId,
  pluginValues,
  pluginData,
  onChange,
  handleInvalidField,
  isLoading,
}) => {
  useEffect(() => {
    onChange({ activationKeys: [] });
  }, [onChange, organizationId, hostGroupId]);

  return (
    <ActivationKeys
      activationKeys={pluginData?.activationKeys}
      organizationId={organizationId}
      selectedKeys={pluginValues?.activationKeys || []}
      hostGroupActivationKeys={pluginData?.hostGroupActivationKeys}
      hostGroupId={hostGroupId}
      pluginValues={pluginValues}
      onChange={onChange}
      handleInvalidField={handleInvalidField}
      isLoading={isLoading}
    />
  );
};

RegistrationActivationKeys.propTypes = {
  organizationId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  hostGroupId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  pluginValues: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  pluginData: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  onChange: PropTypes.func,
  handleInvalidField: PropTypes.func,
  isLoading: PropTypes.bool,
};

RegistrationActivationKeys.defaultProps = {
  organizationId: undefined,
  hostGroupId: undefined,
  pluginValues: {},
  pluginData: {},
  isLoading: false,
  onChange: noop,
  handleInvalidField: noop,
};
