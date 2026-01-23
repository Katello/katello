import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Modal,
  Button,
  TextContent,
  Text,
  TextVariants,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import { ENVIRONMENT_PATHS_KEY } from '../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathConstants';
import api from '../../../../services/api';
import { OrderableAssignmentList } from '../../../../components/extensions/HostDetails/Cards/ContentViewDetailsCard/OrderableAssignments';

const ENV_PATH_OPTIONS = { key: ENVIRONMENT_PATHS_KEY };

const AddAnotherCVButton = ({ onClick, isDisabled }) => (
  <>
    <hr style={{ margin: '1rem 0' }} />
    <Button
      variant="link"
      icon={<span style={{ fontSize: '1.2em', marginRight: '0.5rem' }}>+</span>}
      onClick={onClick}
      ouiaId="assign-another-cv-button"
      style={{ paddingLeft: 0 }}
      isDisabled={isDisabled}
    >
      {__('Assign another content view environment')}
    </Button>
  </>
);

AddAnotherCVButton.propTypes = {
  onClick: PropTypes.func.isRequired,
  isDisabled: PropTypes.bool.isRequired,
};

const CreateAKCVModal = ({
  isOpen,
  closeModal,
  orgId,
  existingAssignments,
  onAssignmentsChange,
  allowMultipleContentViews,
}) => {
  const [assignments, setAssignments] = useState([]);
  const [initialAssignments, setInitialAssignments] = useState([]);

  const pathsUrl = `/organizations/${orgId}/environments/paths?permission_type=promotable`;
  useAPI('get', api.getApiUrl(pathsUrl), ENV_PATH_OPTIONS);

  const handleModalClose = () => {
    setAssignments([]);
    setInitialAssignments([]);
    closeModal();
  };

  const handleAssignmentsChange = (newAssignments) => {
    setAssignments(newAssignments);
    // Store initial assignments on first change (when modal opens)
    if (initialAssignments.length === 0 && newAssignments.length > 0) {
      setInitialAssignments(newAssignments);
    }
  };

  // Helper to normalize assignments for comparison
  const normalizeAssignment = a => ({
    cvName: a.selectedCV || a.contentView?.name,
    envId: a.selectedEnv?.[0]?.id || a.environment?.id,
  });

  // Check if assignments have changed from initial state
  const hasChanges = () => {
    if (assignments.length !== initialAssignments.length) return true;

    const currentNormalized = assignments.map(normalizeAssignment);
    const initialNormalized = initialAssignments.map(normalizeAssignment);

    return !currentNormalized.every((curr, idx) => {
      const init = initialNormalized[idx];
      return curr.cvName === init.cvName && curr.envId === init.envId;
    });
  };

  // Allow zero assignments for activation keys
  // When allowMultipleContentViews is false, only allow saving with 0 or 1 assignment
  const canSave =
    assignments.every(a => a.selectedCV && a.selectedEnv.length > 0) &&
    hasChanges() &&
    (allowMultipleContentViews || assignments.length <= 1);

  const handleSave = () => {
    // Just pass assignments to parent and close (no API call)
    onAssignmentsChange(assignments);
    handleModalClose();
  };

  const modalActions = [
    <Button
      key="save"
      ouiaId="assign-cv-modal-save-button"
      variant="primary"
      onClick={handleSave}
      isDisabled={!canSave}
    >
      {__('Save')}
    </Button>,
    <Button
      key="cancel"
      ouiaId="assign-cv-modal-cancel-button"
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
      title={__('Assign content view environments')}
      width="50%"
      position="top"
      actions={modalActions}
      id="assign-cv-modal"
      ouiaId="assign-cv-modal"
    >
      <TextContent style={{ marginBottom: '1rem' }}>
        <Text component={TextVariants.p} ouiaId="modal-description">
          {allowMultipleContentViews
            ? __('A content view environment is a combination of a particular lifecycle environment and content view. You can assign multiple content view environments to provide hosts access to multiple sets of content.')
            : __('A content view environment is a combination of a particular lifecycle environment and content view.')
          }
        </Text>
      </TextContent>

      <div className="attached-content-views">
        {assignments.length > 0 && (
          <Text
            component={TextVariants.h3}
            style={{ marginBottom: '0.5rem' }}
            ouiaId="attached-content-views-heading"
          >
            {__('Associated content view environments')}
          </Text>
        )}

        <OrderableAssignmentList
          existingAssignments={existingAssignments}
          isOpen={isOpen}
          onAssignmentsChange={handleAssignmentsChange}
          allowMultipleContentViews={allowMultipleContentViews}
          allowZeroAssignments
          renderAddButton={(addFn, canAdd) => (
            <AddAnotherCVButton onClick={addFn} isDisabled={!canAdd} />
          )}
        />
      </div>
    </Modal>
  );
};

CreateAKCVModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  orgId: PropTypes.number.isRequired,
  existingAssignments: PropTypes.arrayOf(PropTypes.shape({
    contentView: PropTypes.shape({}),
    environment: PropTypes.shape({}),
    label: PropTypes.string,
  })),
  onAssignmentsChange: PropTypes.func.isRequired,
  allowMultipleContentViews: PropTypes.bool,
};

CreateAKCVModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  existingAssignments: [],
  allowMultipleContentViews: false,
};

export default CreateAKCVModal;
