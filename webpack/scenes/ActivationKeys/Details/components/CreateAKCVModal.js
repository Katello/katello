import React from 'react';
import PropTypes from 'prop-types';
import {
  Modal,
  Button,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import { ENVIRONMENT_PATHS_KEY } from '../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathConstants';
import api from '../../../../services/api';
import { OrderableAssignmentList } from '../../../../components/extensions/HostDetails/Cards/ContentViewDetailsCard/OrderableAssignments';
import useAssignmentManagement from '../hooks/useAssignmentManagement';
import {
  AddAnotherCVButton,
  AssignmentModalDescription,
  AssignmentsHeading,
} from './AssignmentModalComponents';

const ENV_PATH_OPTIONS = { key: ENVIRONMENT_PATHS_KEY };

const CreateAKCVModal = ({
  isOpen,
  closeModal,
  orgId,
  existingAssignments,
  onAssignmentsChange,
  allowMultipleContentViews,
}) => {
  const {
    assignments,
    handleAssignmentsChange,
    resetState,
    canSave,
  } = useAssignmentManagement(allowMultipleContentViews);

  const pathsUrl = `/organizations/${orgId}/environments/paths?permission_type=promotable`;
  useAPI(isOpen ? 'get' : null, api.getApiUrl(pathsUrl), ENV_PATH_OPTIONS);

  const handleModalClose = () => {
    resetState();
    closeModal();
  };

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
      <AssignmentModalDescription allowMultipleContentViews={allowMultipleContentViews} />

      <div className="attached-content-views">
        <AssignmentsHeading show={assignments.length > 0} />

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
