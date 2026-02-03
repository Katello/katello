import React from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import {
  Modal,
  Button,
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
import useAssignmentManagement, { constructCVELabel } from '../hooks/useAssignmentManagement';
import {
  AddAnotherCVButton,
  AssignmentModalDescription,
  AssignmentsHeading,
} from './AssignmentModalComponents';

const ENV_PATH_OPTIONS = { key: ENVIRONMENT_PATHS_KEY };

const AssignAKCVModal = ({
  isOpen,
  closeModal,
  orgId,
  akId,
  existingAssignments,
  allowMultipleContentViews,
}) => {
  const {
    assignments,
    handleAssignmentsChange,
    resetState,
    canSave,
  } = useAssignmentManagement(allowMultipleContentViews);

  const dispatch = useDispatch();

  const akUpdateStatus = useSelector(state =>
    selectAPIStatus(state, AK_CV_AND_ENV_KEY));

  const pathsUrl = `/organizations/${orgId}/environments/paths?permission_type=promotable`;
  useAPI('get', api.getApiUrl(pathsUrl), ENV_PATH_OPTIONS);

  const handleModalClose = () => {
    resetState();
    closeModal();
  };

  const refreshPage = async () => {
    handleModalClose();

    try {
      // Access Angular's injector to get the ActivationKey service
      const angularElement = window.angular?.element(document.getElementById('ak-cve-details'));
      if (!angularElement) {
        // Fallback to page reload if Angular not available
        window.location.reload();
        return;
      }

      const injector = angularElement.injector();
      if (!injector) {
        window.location.reload();
        return;
      }

      const ActivationKey = injector.get('ActivationKey');
      const scope = angularElement.scope();

      if (!scope) {
        window.location.reload();
        return;
      }

      // Re-fetch the activation key using Angular's ActivationKey service
      // This ensures we get a proper BastionResource instance with $update(), $delete() methods
      let updatedAk;
      scope.$apply(() => {
        updatedAk = ActivationKey.get({ id: akId });
      });

      // Wait for the promise to resolve, then update both Angular scope and DOM
      try {
        const response = await updatedAk.$promise;
        scope.$apply(() => {
          scope.activationKey = updatedAk; // Assign the resource instance (not the response)
        });

        // Update the DOM element that the React component watches
        const akDetailsNode = document.getElementById('ak-cve-details');
        if (akDetailsNode) {
          akDetailsNode.setAttribute('data-ak-details', JSON.stringify(response));
        }
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error('Failed to refresh activation key:', error);
        window.location.reload();
      }
    } catch (error) {
      // Fallback to page reload if anything fails
      // eslint-disable-next-line no-console
      console.error('Failed to refresh activation key data:', error);
      window.location.reload();
    }
  };

  const handleSave = () => {
    // Build array of content view environment labels for all assignments
    // Backend processes either IDs OR labels, not both (elsif in backend code)
    // So we use labels for everything to support mixed existing+new assignments
    const cveLabels = assignments
      .map(constructCVELabel)
      .filter(Boolean); // Remove any null values (incomplete assignments)

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
      <AssignmentModalDescription allowMultipleContentViews={allowMultipleContentViews} />

      <div className="attached-content-views">
        <AssignmentsHeading show={existingAssignments.length > 0} />

        <OrderableAssignmentList
          existingAssignments={existingAssignments}
          isOpen={isOpen}
          assignmentStatus={akUpdateStatus}
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
  allowMultipleContentViews: PropTypes.bool,
};

AssignAKCVModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  existingAssignments: [],
  allowMultipleContentViews: false,
};

export default AssignAKCVModal;
