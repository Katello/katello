import React, { useState } from 'react';
import {
  Modal,
  Button,
  Form,
  FormGroup,
  FormSelect,
  FormSelectOption,
  Select,
  SelectOption,
  SelectVariant,
} from '@patternfly/react-core';
import { FormattedMessage } from 'react-intl';
import { translate as __ } from 'foremanReact/common/I18n';

const SystemPurposeEditModal = ({
  closeModal, hostName, purposeRole, purposeUsage, purposeAddons,
  serviceLevel, releaseVersion,
}) => {
  const unmodified = false;
  const [addonSelectOpen, setAddonSelectOpen] = useState(false);
  const [selectedAddons, setSelectedAddons] = useState([]);

  const toggleAddonSelect = () => setAddonSelectOpen(prev => !prev);

  const onAddonSelect = (_event, selected) => {
    const newSelectedAddons = new Set(selectedAddons);
    if (!selected) return;
    if (newSelectedAddons.has(selected)) {
      newSelectedAddons.delete(selected);
    } else {
      newSelectedAddons.add(selected);
    }
    setSelectedAddons([...newSelectedAddons]);
  };


  const modalActions = ([
    <Button key="save-syspurpose" variant="primary" onClick={closeModal} isDisabled={unmodified}>
      {__('Save')}
    </Button>,
    <Button key="cancel" variant="link" onClick={closeModal}>
      {__('Cancel')}
    </Button>,
  ]);

  const roleOptions = [
    { label: __('Unspecified'), value: 'unspecified' },
    { label: __('Management'), value: 'management' },
    { label: __('User'), value: 'user' },
  ];

  const usageOptions = [
    { label: __('Unspecified'), value: 'unspecified' },
    { label: __('Production'), value: 'production' },
    { label: __('Development'), value: 'development' },
    { label: __('Test'), value: 'test' },
  ];

  const addonsOptions = [
    { label: __('Add-on 1'), value: 'addon1' },
    { label: __('Add-on 2'), value: 'addon2' },
  ];

  const releaseVersionOptions = [
    { label: __('6'), value: 'rhel-6' },
    { label: __('7'), value: 'rhel-7' },
    { label: __('8'), value: 'rhel-8' },
    { label: __('9'), value: 'rhel-9' },
  ];

  const serviceLevelOptions = [
    { label: __('Premium'), value: 'premium' },
    { label: __('Standard'), value: 'standard' },
    { label: __('Basic'), value: 'basic' },
  ];

  return (
    <Modal
      isOpen
      onClose={closeModal}
      title={__('Edit system purpose attributes')}
      width="50%"
      position="top"
      actions={modalActions}
      id="syspurpose-edit-modal"
    >
      <FormattedMessage
        className="syspurpose-edit-modal-blurb"
        id="syspurpose-edit-modal-blurb"
        defaultMessage={__('Select system purpose attributes for host {hostName}.')}
        values={{
          hostName: <strong>{hostName}</strong>,
        }}
      />
      <Form isHorizontal>
        <FormGroup label={__('Role')}>
          <FormSelect
            id="role"
            name="role"
            value={purposeRole}
            onChange={() => {}}
          >
            {roleOptions.map(option => (
              <FormSelectOption
                key={option.value}
                value={option.value}
                label={option.label}
              />
            ))}
          </FormSelect>
        </FormGroup>
        <FormGroup label={__('SLA')}>
          <FormSelect
            id="serviceLevel"
            name="serviceLevel"
            value={serviceLevel}
            onChange={() => {}}
          >
            {serviceLevelOptions.map(option => (
              <FormSelectOption
                key={option.value}
                value={option.value}
                label={option.label}
              />
            ))}
          </FormSelect>
        </FormGroup>
        <FormGroup label={__('Usage')}>
          <FormSelect
            id="usage"
            name="usage"
            value={purposeUsage}
            onChange={() => {}}
          >
            {usageOptions.map(option => (
              <FormSelectOption
                key={option.value}
                value={option.value}
                label={option.label}
              />
            ))}
          </FormSelect>
        </FormGroup>
        <FormGroup label={__('Add-ons')}>
          <span id="syspurpose-addons-title" hidden>
            Checkbox Title
          </span>
          <Select
            variant={SelectVariant.checkbox}
            aria-label="syspurpose-addons"
            onToggle={toggleAddonSelect}
            onSelect={onAddonSelect}
            selections={selectedAddons}
            isOpen={addonSelectOpen}
            placeholderText="Select add-ons"
            aria-labelledby="syspurpose-addons-title"
          >
            {addonsOptions.map(option => (
              <SelectOption
                key={option.value}
                value={option.value}
                label={option.label}
              />
            ))}
          </Select>
        </FormGroup>
        <FormGroup label={__('Release version')}>
          <FormSelect
            id="release_version"
            name="release_version"
            value={releaseVersion}
            onChange={() => {}}
          >
            {releaseVersionOptions.map(option => (
              <FormSelectOption
                key={option.value}
                value={option.value}
                label={option.label}
              />
            ))}
          </FormSelect>
        </FormGroup>
      </Form>
    </Modal>
  );
};

export default SystemPurposeEditModal;