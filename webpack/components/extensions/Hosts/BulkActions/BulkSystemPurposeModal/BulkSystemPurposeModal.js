import React, { useState, useEffect, useCallback } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import {
  Modal,
  Button,
  Form,
  FormGroup,
  FormSelect,
  FormSelectOption,
  TextContent,
  Text,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { selectAPIStatus } from 'foremanReact/redux/API/APISelectors';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import api from '../../../../../services/api';
import {
  selectOrganization,
  selectOrganizationStatus,
} from '../../../HostDetails/Cards/SystemPurposeCard/SystemPurposeSelectors';
import { getOrganization } from '../../../HostDetails/Cards/SystemPurposeCard/SystemPurposeActions';
import {
  defaultUsages,
  defaultRoles,
  defaultServiceLevels,
} from '../../../HostDetails/Cards/SystemPurposeCard/SystemPurposeConstants';
import { buildSystemPurposeOptions } from '../../../HostDetails/Cards/SystemPurposeCard/helpers';
import {
  bulkUpdateHostSystemPurpose,
  bulkUpdateHostReleaseVersion,
  BULK_SYSTEM_PURPOSE_KEY,
  BULK_RELEASE_VERSION_KEY,
} from './actions';

const NO_CHANGE = '__no_change__';

const BulkSystemPurposeModal = ({
  isOpen,
  closeModal,
  selectedCount,
  orgId,
  fetchBulkParams,
}) => {
  const [selectedRole, setSelectedRole] = useState(NO_CHANGE);
  const [selectedUsage, setSelectedUsage] = useState(NO_CHANGE);
  const [selectedServiceLevel, setSelectedServiceLevel] = useState(NO_CHANGE);
  const [selectedReleaseVersion, setSelectedReleaseVersion] = useState(NO_CHANGE);
  const [availableReleaseVersions, setAvailableReleaseVersions] = useState([]);
  const [isSaving, setIsSaving] = useState(false);
  const [sysPurposeDispatched, setSysPurposeDispatched] = useState(false);
  const [releaseVersionDispatched, setReleaseVersionDispatched] = useState(false);

  const dispatch = useDispatch();

  const orgStatus = useSelector(state => selectOrganizationStatus(state, orgId));
  const organizationDetails = useSelector(state => selectOrganization(state, orgId));
  const orgDetails = propsToCamelCase(organizationDetails ?? { systemPurposes: {} });
  const availableSyspurposeAttributes = orgDetails?.systemPurposes ?? {};
  const availableServiceLevels = orgDetails?.serviceLevels ?? [];
  const { roles: availableRoles, usage: availableUsages } = availableSyspurposeAttributes;

  const sysPurposeStatus = useSelector(state =>
    selectAPIStatus(state, BULK_SYSTEM_PURPOSE_KEY));
  const releaseVersionStatus = useSelector(state =>
    selectAPIStatus(state, BULK_RELEASE_VERSION_KEY));

  // Check if either API call is pending
  const isUpdating =
    sysPurposeStatus === STATUS.PENDING || releaseVersionStatus === STATUS.PENDING;

  useEffect(() => {
    if (orgId && orgStatus !== STATUS.RESOLVED) {
      dispatch(getOrganization({ orgId }));
    }
  }, [orgId, orgStatus, dispatch]);

  useEffect(() => {
    let canceled = false;
    const fetchReleases = async () => {
      if (isOpen && orgId) {
        try {
          const response = await api.get(`/organizations/${orgId}/releases`);
          if (!canceled) {
            setAvailableReleaseVersions(response.data.results || []);
          }
        } catch (error) {
          if (!canceled) {
            // eslint-disable-next-line no-console
            console.error('Error fetching releases:', error);
            setAvailableReleaseVersions([]);
          }
        }
      }
    };
    fetchReleases();
    return () => { canceled = true; };
  }, [isOpen, orgId]);

  const handleModalClose = useCallback(() => {
    setSelectedRole(NO_CHANGE);
    setSelectedUsage(NO_CHANGE);
    setSelectedServiceLevel(NO_CHANGE);
    setSelectedReleaseVersion(NO_CHANGE);
    setAvailableReleaseVersions([]);
    setIsSaving(false);
    setSysPurposeDispatched(false);
    setReleaseVersionDispatched(false);
    closeModal();
  }, [closeModal]);

  // Close modal when all dispatched API calls complete
  useEffect(() => {
    if (!isSaving) return;

    const sysPurposeComplete =
      !sysPurposeDispatched || sysPurposeStatus !== STATUS.PENDING;
    const releaseVersionComplete =
      !releaseVersionDispatched || releaseVersionStatus !== STATUS.PENDING;

    if (sysPurposeComplete && releaseVersionComplete) {
      handleModalClose();
    }
  }, [
    isSaving,
    sysPurposeDispatched,
    releaseVersionDispatched,
    sysPurposeStatus,
    releaseVersionStatus,
    handleModalClose,
  ]);

  const roleOptions = buildSystemPurposeOptions(
    defaultRoles,
    availableRoles,
    { includeNoChange: true, noChangeValue: NO_CHANGE },
  );

  const usageOptions = buildSystemPurposeOptions(
    defaultUsages,
    availableUsages,
    { includeNoChange: true, noChangeValue: NO_CHANGE },
  );

  const serviceLevelOptions = buildSystemPurposeOptions(
    defaultServiceLevels,
    availableServiceLevels,
    { includeNoChange: true, noChangeValue: NO_CHANGE },
  );

  const releaseVersionOptions = buildSystemPurposeOptions(
    [],
    availableReleaseVersions,
    { includeNoChange: true, noChangeValue: NO_CHANGE },
  );

  const hasChanges = () =>
    selectedRole !== NO_CHANGE ||
    selectedUsage !== NO_CHANGE ||
    selectedServiceLevel !== NO_CHANGE ||
    selectedReleaseVersion !== NO_CHANGE;

  const handleSave = () => {
    const baseParams = {
      organization_id: orgId,
      included: {
        search: fetchBulkParams(),
      },
    };

    // Start saving process
    setIsSaving(true);
    setSysPurposeDispatched(false);
    setReleaseVersionDispatched(false);

    // Call system purpose endpoint if any system purpose fields changed
    if (selectedRole !== NO_CHANGE ||
        selectedUsage !== NO_CHANGE ||
        selectedServiceLevel !== NO_CHANGE) {
      const sysPurposeParams = { ...baseParams };

      if (selectedRole !== NO_CHANGE) {
        sysPurposeParams.purpose_role = selectedRole;
      }
      if (selectedUsage !== NO_CHANGE) {
        sysPurposeParams.purpose_usage = selectedUsage;
      }
      if (selectedServiceLevel !== NO_CHANGE) {
        sysPurposeParams.service_level = selectedServiceLevel;
      }

      dispatch(bulkUpdateHostSystemPurpose(sysPurposeParams));
      setSysPurposeDispatched(true);
    }

    // Call release version endpoint if release version changed
    if (selectedReleaseVersion !== NO_CHANGE) {
      const releaseParams = {
        ...baseParams,
        release_version: selectedReleaseVersion,
      };

      dispatch(bulkUpdateHostReleaseVersion(releaseParams));
      setReleaseVersionDispatched(true);
    }
  };

  const modalActions = [
    <Button
      key="save"
      ouiaId="bulk-system-purpose-modal-save-button"
      variant="primary"
      onClick={handleSave}
      isDisabled={!hasChanges() || isUpdating}
      isLoading={isUpdating}
    >
      {__('Save')}
    </Button>,
    <Button
      key="cancel"
      ouiaId="bulk-system-purpose-modal-cancel-button"
      variant="link"
      onClick={handleModalClose}
    >
      {__('Cancel')}
    </Button>,
  ];

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleModalClose}
      onEscapePress={handleModalClose}
      title={__('Change system purpose')}
      width="50%"
      position="top"
      actions={modalActions}
      id="bulk-system-purpose-modal"
      key="bulk-system-purpose-modal"
      ouiaId="bulk-system-purpose-modal"
    >
      <TextContent>
        <Text ouiaId="bulk-system-purpose-description">
          <FormattedMessage
            defaultMessage="This will update the system purpose for {hosts}. Not all releases may be compatible with all selected hosts."
            values={{
              hosts: (
                <strong>
                  <FormattedMessage
                    defaultMessage="{count, plural, one {# {singular}} other {# {plural}}}"
                    values={{
                      count: selectedCount,
                      singular: __('selected host'),
                      plural: __('selected hosts'),
                    }}
                    id="bulk-system-purpose-count"
                  />
                </strong>
              ),
            }}
            id="bulk-system-purpose-description-i18n"
          />
        </Text>
      </TextContent>

      <Form>
        <FormGroup label={__('Role')} fieldId="bulk-system-purpose-role">
          <FormSelect
            value={selectedRole}
            onChange={(_event, value) => setSelectedRole(value)}
            id="bulk-system-purpose-role"
            ouiaId="bulk-system-purpose-role-select"
            isDisabled={isUpdating}
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

        <FormGroup label={__('Usage')} fieldId="bulk-system-purpose-usage">
          <FormSelect
            value={selectedUsage}
            onChange={(_event, value) => setSelectedUsage(value)}
            id="bulk-system-purpose-usage"
            ouiaId="bulk-system-purpose-usage-select"
            isDisabled={isUpdating}
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

        <FormGroup label={__('Service level (SLA)')} fieldId="bulk-system-purpose-sla">
          <FormSelect
            value={selectedServiceLevel}
            onChange={(_event, value) => setSelectedServiceLevel(value)}
            id="bulk-system-purpose-sla"
            ouiaId="bulk-system-purpose-sla-select"
            isDisabled={isUpdating}
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

        <FormGroup label={__('Release version')} fieldId="bulk-system-purpose-release">
          <FormSelect
            value={selectedReleaseVersion}
            onChange={(_event, value) => setSelectedReleaseVersion(value)}
            id="bulk-system-purpose-release"
            ouiaId="bulk-system-purpose-release-select"
            isDisabled={isUpdating}
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

BulkSystemPurposeModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func.isRequired,
  selectedCount: PropTypes.number.isRequired,
  orgId: PropTypes.number.isRequired,
  fetchBulkParams: PropTypes.func.isRequired,
};

BulkSystemPurposeModal.defaultProps = {
  isOpen: false,
};

export default BulkSystemPurposeModal;
