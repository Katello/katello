import React, { useState, useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { isEqual } from 'lodash';
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
import { getHostAvailableReleaseVersions, getAKAvailableReleaseVersions, getOrganization, updateHostSysPurposeAttributes, updateAKSysPurposeAttributes } from './SystemPurposeActions';
import HOST_DETAILS_KEY from '../../HostDetailsConstants';
import { defaultUsages, defaultRoles, defaultServiceLevels } from './SystemPurposeConstants';
import { getActivationKey } from '../../../../../scenes/ActivationKeys/Details/ActivationKeyActions';

const SystemPurposeEditModal = ({
  closeModal, name, purposeRole, purposeUsage, purposeAddons,
  serviceLevel, releaseVersion, isOpen, orgId, id, type,
}) => {
  const initialPurposeRole = purposeRole ?? '';
  const initialServiceLevel = serviceLevel ?? '';
  const initialPurposeUsage = purposeUsage ?? '';
  const initialReleaseVersion = releaseVersion ?? '';
  const initialPurposeAddons = purposeAddons ?? [];
  const [selectedRole, setSelectedRole] = useState(initialPurposeRole);
  const [selectedServiceLevel, setSelectedServiceLevel] = useState(initialServiceLevel);
  const [selectedUsage, setSelectedUsage] = useState(initialPurposeUsage);
  const [addonSelectOpen, setAddonSelectOpen] = useState(false);
  const [selectedAddons, setSelectedAddons] = useState(initialPurposeAddons);
  const [selectedReleaseVersion, setSelectedReleaseVersion] = useState(initialReleaseVersion);

  const unmodified = (
    selectedRole === initialPurposeRole &&
    selectedServiceLevel === initialServiceLevel &&
    selectedUsage === initialPurposeUsage &&
    selectedReleaseVersion === initialReleaseVersion &&
    isEqual(selectedAddons, initialPurposeAddons)
  );
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
    selectAvailableReleaseVersions(state, id))?.results ?? [];
  useEffect(() => {
    if (orgId && orgStatus !== STATUS.RESOLVED) {
      dispatch(getOrganization({ orgId }));
    }
  }, [orgId, orgStatus, dispatch]);

  useEffect(() => {
    if (type === 'host' && id && availableReleaseVersionsStatus !== STATUS.RESOLVED) {
      dispatch(getHostAvailableReleaseVersions({ id }));
    } else if (type === 'ak' && id) {
      dispatch(getAKAvailableReleaseVersions({ id }));
    }
  }, [type, id, availableReleaseVersionsStatus, dispatch]);

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
      url: `/api/hosts/${name}`,
    },
  });

  // Building the dropdown options is a bit complex because they come from several sources:
  // 1. The hard-coded set of default values (defaultOptions)
  // 2. The set of available values from the API (additionalOptions)
  // 3. The value actually set on the host (initialOption - this need not be a value from 1 or 2)
  // We then need to combine these values into a single set of options, and ensure that
  // (a) (unset) appears first;
  // (b) there are no duplicate options;
  // (c) that the currently selected option always appears (currentSelected); and
  // (d) that the order of the items doesn't change unexpectedly.
  const buildOptions = (defaultOptions, additionalOptions, currentSelected, initialOption) => {
    const optionToObject = option => ({ label: option || __('(unset)'), value: option });
    const uniqOptions = new Set(['', ...defaultOptions ?? [], ...additionalOptions ?? [], currentSelected, initialOption]);
    uniqOptions.delete(null);
    uniqOptions.delete(undefined);
    return [...[...uniqOptions]?.map(optionToObject)];
  };

  const roleOptions =
    buildOptions(defaultRoles, availableRoles, selectedRole, purposeRole);
  const usageOptions =
    buildOptions(defaultUsages, availableUsages, selectedUsage, purposeUsage);

  // addons may be present on the host but not available from subscriptions,
  // so we combine the options here
  const addonToObject = addon => ({ label: addon, value: addon });
  const addonsOptions =
    [...new Set([ // don't repeat addons if they are already selected
      ...purposeAddons.map(addonToObject), ...availableAddons?.map(addonToObject) ?? [],
    ])];

  const serviceLevelOptions =
    buildOptions(defaultServiceLevels, availableServiceLevels, selectedServiceLevel, serviceLevel);

  const releaseVersionOptions =
    buildOptions([], availableReleaseVersions, selectedReleaseVersion, releaseVersion);

  const handleSave = (event) => {
    event.preventDefault();
    closeModal();
    const optionsToValue = (options, stateValue) =>
      options.find(option => option.value === stateValue)?.value;
    if (type === 'host') {
      dispatch(updateHostSysPurposeAttributes({
        id,
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
    } else {
      dispatch(updateAKSysPurposeAttributes({
        id,
        attributes: {
          autoheal: true,
          purpose_role: optionsToValue(roleOptions, selectedRole),
          purpose_usage: optionsToValue(usageOptions, selectedUsage),
          purpose_addons: selectedAddons,
          release_version: optionsToValue(releaseVersionOptions, selectedReleaseVersion),
          service_level: optionsToValue(serviceLevelOptions, selectedServiceLevel),
        },
        refreshAKDetails: () => dispatch(getActivationKey(id)),
      }));
    }
  };

  const handleCancel = () => {
    setSelectedRole(initialPurposeRole);
    setSelectedServiceLevel(initialServiceLevel);
    setSelectedUsage(initialPurposeUsage);
    setSelectedAddons(initialPurposeAddons);
    setSelectedReleaseVersion(initialReleaseVersion);
    closeModal();
  };

  const modalActions = ([
    <Button ouiaId="save-syspurpose" key="save-syspurpose" variant="primary" onClick={handleSave} isDisabled={unmodified}>
      {__('Save')}
    </Button>,
    <Button ouiaId="cancel-syspurpose" key="cancel" variant="link" onClick={handleCancel}>
      {__('Cancel')}
    </Button>,
  ]);


  return (
    <Modal
      isOpen={isOpen}
      onClose={handleCancel}
      title={__('Edit system purpose attributes')}
      width="40%"
      position="top"
      actions={modalActions}
      id="syspurpose-edit-modal"
      ouiaId="syspurpose-edit-modal"
    >
      <FormattedMessage
        className="syspurpose-edit-modal-blurb"
        id="syspurpose-edit-modal-blurb"
        defaultMessage={type === 'host' ? __('Select system purpose attributes for host {name}.') : __('Select system purpose attributes for activation key {name}.')}
        values={{
          name: <strong>{name}</strong>,
        }}
      />
      <Form isHorizontal style={{ marginTop: '1.3rem' }}>
        <FormGroup label={__('Role')} fieldId="role">
          <FormSelect
            id="role"
            name="role"
            ouiaId="role-select"
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
        <FormGroup label={__('SLA')} fieldId="serviceLevel">
          <FormSelect
            id="serviceLevel"
            name="serviceLevel"
            ouiaId="service-level-select"
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
        <FormGroup label={__('Usage')} fieldId="usage">
          <FormSelect
            id="usage"
            name="usage"
            ouiaId="usage-select"
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
        <FormGroup label={__('Release version')} fieldId="releaseVersion">
          <FormSelect
            id="release_version"
            name="release_version"
            ouiaId="release-version-select"
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
        <FormGroup label={__('Add-ons')} fieldId="addons">
          <span id="syspurpose-addons-title" hidden>
            Checkbox Title
          </span>
          <Select
            variant={SelectVariant.typeaheadMulti}
            aria-label="syspurpose-addons"
            ouiaId="syspurpose-addons-select"
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
  name: PropTypes.string,
  purposeRole: PropTypes.string.isRequired,
  purposeUsage: PropTypes.string.isRequired,
  purposeAddons: PropTypes.arrayOf(PropTypes.string).isRequired,
  serviceLevel: PropTypes.string.isRequired,
  releaseVersion: PropTypes.string,
  isOpen: PropTypes.bool.isRequired,
  orgId: PropTypes.number,
  id: PropTypes.number,
  type: PropTypes.string.isRequired,
};

SystemPurposeEditModal.defaultProps = {
  name: '',
  orgId: null,
  id: null,
  releaseVersion: '',
};
