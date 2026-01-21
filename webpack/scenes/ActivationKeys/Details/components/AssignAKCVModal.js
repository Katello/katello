import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import {
  Modal,
  Button,
  TextContent,
  Text,
  TextVariants,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import { selectAPIStatus } from 'foremanReact/redux/API/APISelectors';
import { ENVIRONMENT_PATHS_KEY } from '../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathConstants';
import api from '../../../../services/api';
import assignAKCVEnvironments from './AKContentViewActions';
import AK_CV_AND_ENV_KEY from './AKContentViewConstants';
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
      {__('Assign another content view')}
    </Button>
  </>
);

AddAnotherCVButton.propTypes = {
  onClick: PropTypes.func.isRequired,
  isDisabled: PropTypes.bool.isRequired,
};

const AssignAKCVModal = ({
  isOpen,
  closeModal,
  orgId,
  akId,
  existingAssignments,
}) => {
  const [assignments, setAssignments] = useState([]);
  const [initialAssignments, setInitialAssignments] = useState([]);
  const dispatch = useDispatch();

  const akUpdateStatus = useSelector(state =>
    selectAPIStatus(state, AK_CV_AND_ENV_KEY));

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

  // Allow zero assignments for activation keys (unlike hosts)
  const canSave =
    assignments.every(a => a.selectedCV && a.selectedEnv.length > 0) &&
    hasChanges();

  const refreshPage = async () => {
    handleModalClose();

    // Fetch updated activation key data
    try {
      const response = await fetch(api.getApiUrl(`/activation_keys/${akId}`), {
        headers: {
          'Content-Type': 'application/json',
        },
        credentials: 'include',
      });

      if (response.ok) {
        const updatedAkData = await response.json();

        // Update the DOM element that the React component watches
        const akDetailsNode = document.getElementById('ak-cve-details');
        if (akDetailsNode) {
          akDetailsNode.setAttribute('data-ak-details', JSON.stringify(updatedAkData));
        }

        // Update Angular scope if available
        const angularElement = window.angular?.element(document.getElementById('ak-cve-details'));
        if (angularElement) {
          const scope = angularElement.scope();
          if (scope) {
            scope.$apply(() => {
              scope.activationKey = updatedAkData;
            });
          }
        }
      } else {
        // Fallback to page reload if fetch fails
        window.location.reload();
      }
    } catch (error) {
      // Fallback to page reload if fetch fails
      // eslint-disable-next-line no-console
      console.error('Failed to refresh activation key data:', error);
      window.location.reload();
    }
  };

  const handleSave = () => {
    // Build array of content view environment labels for all assignments
    // Backend processes either IDs OR labels, not both (elsif in backend code)
    // So we use labels for everything to support mixed existing+new assignments
    const cveLabels = [];

    assignments.forEach((a) => {
      // For existing assignments that have a pre-computed label, use it directly
      if (a.label) {
        cveLabels.push(a.label);
        return;
      }

      // For new assignments, build the label from the selected values
      // selectedEnv is an array with one item
      const env = a.selectedEnv?.[0];
      const cv = a.contentView; // contentView is updated when CV is selected

      if (env?.label && cv?.label) {
        const envLabel = env.label;
        const cvLabel = cv.label;

        // Content view environment label format matches backend logic:
        // - For default content view in Library lifecycle environment:
        //   just "Library" (default_environment?)
        // - For default content view in non-Library lifecycle environment:
        //   "Production/Default Organization View"
        // - For non-default content view:
        //   "lifecycle_environment_label/content_view_label"
        const isLibraryEnv = env.lifecycle_environment_library || env.library;
        const isDefaultCV = cv.content_view_default || cv.default;
        const cveLabel =
          isDefaultCV && isLibraryEnv ? envLabel : `${envLabel}/${cvLabel}`;

        cveLabels.push(cveLabel);
      }
    });

    const requestBody = {
      id: akId,
      content_view_environments: cveLabels, // Can be empty array for activation keys
    };

    dispatch(assignAKCVEnvironments(
      requestBody,
      akId,
      refreshPage,
      handleModalClose,
    ));
  };

  const modalActions = [
    <Button
      key="save"
      ouiaId="assign-cv-modal-save-button"
      variant="primary"
      onClick={handleSave}
      isDisabled={!canSave}
      isLoading={akUpdateStatus === STATUS.PENDING}
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
          {__('A content view environment is a combination of a particular lifecycle environment and content view. You can assign multiple content view environments to provide hosts access to multiple sets of content.')}
        </Text>
      </TextContent>

      <div className="attached-content-views">
        <Text
          component={TextVariants.h3}
          style={{ marginBottom: '0.5rem' }}
          ouiaId="attached-content-views-heading"
        >
          {__('Associated content view environments')}
        </Text>

        <OrderableAssignmentList
          existingAssignments={existingAssignments}
          isOpen={isOpen}
          assignmentStatus={akUpdateStatus}
          onAssignmentsChange={handleAssignmentsChange}
          renderAddButton={(addFn, canAdd) => (
            <AddAnotherCVButton onClick={addFn} isDisabled={!canAdd} />
          )}
        />
      </div>
    </Modal>
  );
};

AssignAKCVModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  orgId: PropTypes.number.isRequired,
  akId: PropTypes.number.isRequired,
  existingAssignments: PropTypes.arrayOf(PropTypes.shape({
    contentView: PropTypes.shape({}),
    environment: PropTypes.shape({}),
    label: PropTypes.string, // Pre-computed label from backend
  })),
};

AssignAKCVModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  existingAssignments: [],
};

export default AssignAKCVModal;
