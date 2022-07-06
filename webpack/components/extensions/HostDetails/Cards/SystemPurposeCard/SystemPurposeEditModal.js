import React, { useState, useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { STATUS } from 'foremanReact/constants';
import { propsToCamelCase } from 'foremanReact/common/helpers';
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
import { selectOrganizationStatus, selectOrganization, selectAvailableReleaseVersions, selectAvailableReleaseVersionsStatus } from './SystemPurposeSelectors';
import { getAvailableReleaseVersions, getOrganization, updateSystemPurposeAttributes } from './SystemPurposeActions';
import HOST_DETAILS_KEY from '../../HostDetailsConstants';
import { defaultUsages, defaultRoles, defaultServiceLevels } from './SystemPurposeConstants';

const SystemPurposeEditModal = ({
  closeModal, hostName, purposeRole, purposeUsage, purposeAddons,
  serviceLevel, releaseVersion, isOpen, orgId, hostId,
}) => {
  const unmodified = false;
  const [selectedRole, setSelectedRole] = useState(purposeRole);
  const [selectedUsage, setSelectedUsage] = useState(purposeUsage);
  const [addonSelectOpen, setAddonSelectOpen] = useState(false);
  const [selectedAddons, setSelectedAddons] = useState(purposeAddons);
  const [selectedReleaseVersion, setSelectedReleaseVersion] = useState(releaseVersion);
  const [selectedServiceLevel, setSelectedServiceLevel] = useState(serviceLevel);
  const dispatch = useDispatch();

  const orgStatus = useSelector(state => selectOrganizationStatus(state, orgId));
  const organizationDetails = useSelector(state => selectOrganization(state, orgId));
  const orgDetails = propsToCamelCase(organizationDetails ?? { systemPurposes: {} });
  const availableSyspurposeAttributes = orgDetails?.systemPurposes ?? {};
  const availableServiceLevels = orgDetails?.serviceLevels ?? [];
  const { addons: availableAddons, roles: availableRoles, usage: availableUsages }
    = availableSyspurposeAttributes;

  const availableReleaseVersionsStatus
    = useSelector(state => selectAvailableReleaseVersionsStatus(state, orgId));
  const availableReleaseVersions = useSelector(state =>
    selectAvailableReleaseVersions(state, hostId))?.results ?? [];

  useEffect(() => {
    if (orgId && orgStatus !== STATUS.RESOLVED) {
      dispatch(getOrganization({ orgId }));
    }
  }, [orgId, orgStatus, dispatch]);

  useEffect(() => {
    if (hostId && availableReleaseVersionsStatus !== STATUS.RESOLVED) {
      dispatch(getAvailableReleaseVersions({ hostId }));
    }
  }, [hostId, availableReleaseVersionsStatus, dispatch]);

  const toggleAddonSelect = isOpenState => setAddonSelectOpen(isOpenState);

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

  const refreshHostDetails = () => dispatch({
    type: 'API_GET',
    payload: {
      key: HOST_DETAILS_KEY,
      url: `/api/hosts/${hostName}`,
    },
  });

  const buildOptions = (defaultOptions, additionalOptions, currentSelected) => {
    const optionToObject = option => ({ label: option || __('(unset)'), value: option });
    // const unsetOption = { label: __('(unset)'), value: '' };
    // combine default options with additional options,
    // but don't allow duplicates
    const uniqOptions = [...new Set(['', currentSelected, ...defaultOptions ?? [], ...additionalOptions ?? []])];
    return [...uniqOptions?.map(optionToObject)];
  };

  const roleOptions =
    buildOptions(defaultRoles, availableRoles, selectedRole);
  const usageOptions =
    buildOptions(defaultUsages, availableUsages, selectedUsage);

  // addons may be present on the host but not available from subscriptions,
  // so we combine the options here
  const addonToObject = addon => ({ label: addon, value: addon });
  const addonsOptions =
    [...new Set([ // don't repeat addons if they are already selected
      ...purposeAddons.map(addonToObject), ...availableAddons?.map(addonToObject) ?? [],
    ])];

  const serviceLevelOptions =
    buildOptions(defaultServiceLevels, availableServiceLevels, selectedServiceLevel);

  const releaseVersionOptions =
    buildOptions([], availableReleaseVersions, selectedReleaseVersion);

  const handleSave = (event) => {
    event.preventDefault();
    closeModal();
    const optionsToValue = (options, stateValue) =>
      options.find(option => option.value === stateValue)?.value;
    dispatch(updateSystemPurposeAttributes({
      hostId,
      attributes: {
        autoheal: true,
        purpose_role: optionsToValue(roleOptions, selectedRole),
        purpose_usage: optionsToValue(usageOptions, selectedUsage),
        purpose_addons: selectedAddons,
        release_version: optionsToValue(releaseVersionOptions, selectedReleaseVersion),
        service_level: optionsToValue(serviceLevelOptions, selectedServiceLevel),
      },
      refreshHostDetails,
    }));
  };

  const modalActions = ([
    <Button key="save-syspurpose" variant="primary" onClick={handleSave} isDisabled={unmodified}>
      {__('Save')}
    </Button>,
    <Button key="cancel" variant="link" onClick={closeModal}>
      {__('Cancel')}
    </Button>,
  ]);


  return (
    <Modal
      isOpen={isOpen}
      onClose={closeModal}
      title={__('Edit system purpose attributes')}
      width="40%"
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
      <Form isHorizontal style={{ marginTop: '1.3rem' }}>
        <FormGroup label={__('Role')}>
          <FormSelect
            id="role"
            name="role"
            value={selectedRole}
            onChange={setSelectedRole}
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
            value={selectedServiceLevel}
            onChange={setSelectedServiceLevel}
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
            value={selectedUsage}
            onChange={setSelectedUsage}
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
        <FormGroup label={__('Release version')}>
          <FormSelect
            id="release_version"
            name="release_version"
            value={selectedReleaseVersion}
            onChange={setSelectedReleaseVersion}
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
        <FormGroup label={__('Add-ons')}>
          <span id="syspurpose-addons-title" hidden>
            Checkbox Title
          </span>
          <Select
            variant={SelectVariant.typeaheadMulti}
            aria-label="syspurpose-addons"
            onToggle={toggleAddonSelect}
            onSelect={onAddonSelect}
            selections={selectedAddons}
            isOpen={addonSelectOpen}
            placeholderText={__('Select add-ons')}
            aria-labelledby="syspurpose-addons-title"
            menuAppendTo="parent"
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
      </Form>
    </Modal>
  );
};

export default SystemPurposeEditModal;

SystemPurposeEditModal.propTypes = {
  closeModal: PropTypes.func.isRequired,
  hostName: PropTypes.string,
  purposeRole: PropTypes.string.isRequired,
  purposeUsage: PropTypes.string.isRequired,
  purposeAddons: PropTypes.arrayOf(PropTypes.string).isRequired,
  serviceLevel: PropTypes.string.isRequired,
  releaseVersion: PropTypes.string.isRequired,
  isOpen: PropTypes.bool.isRequired,
  orgId: PropTypes.number,
  hostId: PropTypes.number,
};

SystemPurposeEditModal.defaultProps = {
  hostName: '',
  orgId: null,
  hostId: null,
};
