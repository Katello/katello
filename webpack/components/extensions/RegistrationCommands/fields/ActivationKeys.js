
/* eslint-disable max-len, react/forbid-prop-types */
import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import {
  FormGroup,
  Select, SelectOption, SelectVariant,
} from '@patternfly/react-core';

import LabelIcon from 'foremanReact/components/common/LabelIcon';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';

import { validateAKField, akHasValidValue } from '../RegistrationCommandsPageHelpers';

const ActivationKeys = ({
  activationKeys,
  selectedKeys,
  hostGroupActivationKeys,
  hostGroupId,
  pluginValues,
  onChange,
  isLoading,
  handleInvalidField,
}) => {
  const [isOpen, setIsOpen] = useState(false);

  const updatePluginValues = (keys) => {
    onChange({ activationKeys: keys });
    handleInvalidField('Activation Keys', akHasValidValue(hostGroupId, pluginValues?.activationKeys, hostGroupActivationKeys));
  };

  const onSelect = (_e, value) => {
    if (selectedKeys.find((key => key === value))) {
      updatePluginValues(selectedKeys.filter(sk => sk !== value));
    } else {
      updatePluginValues([...selectedKeys, value]);
    }
  };

  // Validate field when hostgroup is changed (host group may have some keys)
  useEffect(() => {
    handleInvalidField('Activation Keys', akHasValidValue(hostGroupId, pluginValues?.activationKeys, hostGroupActivationKeys));
  }, [handleInvalidField, hostGroupId, hostGroupActivationKeys, pluginValues]);

  return (
    <FormGroup
      label={__('Activation Keys')}
      fieldId="reg_katello_ak"
      helperText={hostGroupActivationKeys && sprintf('From host group: %s', hostGroupActivationKeys)}
      helperTextInvalid={activationKeys?.length === 0 ? <a href="/activation_keys/new">{__('Create new activation key')}</a> : __('No Activation Keys selected')}
      validated={validateAKField(hostGroupId, pluginValues?.activationKeys, hostGroupActivationKeys)}
      labelIcon={<LabelIcon text={__('Activation key(s) for Subscription Manager.')} />}
      isRequired
    >
      <Select
        ouiaId="reg-katello-ak"
        selections={selectedKeys}
        variant={SelectVariant.typeaheadMulti}
        onToggle={() => setIsOpen(!isOpen)}
        onSelect={onSelect}
        onClear={() => updatePluginValues([])}
        isOpen={isOpen}
        id="reg_katello_ak"
        className="without_select2"
        isDisabled={isLoading || activationKeys?.length === 0}
        placeholderText={activationKeys?.length === 0 ? __('No Activation keys to select') : ''}
      >
        {activationKeys && activationKeys.map(ack => (
          <SelectOption
            key={ack.name}
            value={ack.name}
            description={(ack?.lce ? ack.lce : __('No environment'))}
          />
        ))}
      </Select>
    </FormGroup>);
};


ActivationKeys.propTypes = {
  activationKeys: PropTypes.array,
  selectedKeys: PropTypes.array,
  hostGroupActivationKeys: PropTypes.oneOfType([PropTypes.string, PropTypes.array]),
  hostGroupId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  pluginValues: PropTypes.objectOf(PropTypes.shape({})),
  onChange: PropTypes.func.isRequired,
  handleInvalidField: PropTypes.func.isRequired,
  isLoading: PropTypes.bool,
};

ActivationKeys.defaultProps = {
  activationKeys: undefined,
  selectedKeys: [],
  hostGroupActivationKeys: undefined,
  hostGroupId: undefined,
  pluginValues: {},
  isLoading: false,
};

export default ActivationKeys;
