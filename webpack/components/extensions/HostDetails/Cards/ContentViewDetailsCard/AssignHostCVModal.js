import React, { useState, useRef, useCallback } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import {
  Modal,
  Button,
  Alert,
  Checkbox,
  TextContent,
  Text,
  TextVariants,
} from '@patternfly/react-core';
import { PlusCircleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import { selectAPIStatus } from 'foremanReact/redux/API/APISelectors';
import { ENVIRONMENT_PATHS_KEY } from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathConstants';
import api from '../../../../../services/api';
import {
  assignHostCVEnvironments,
  runSubmanRepos,
} from './HostContentViewActions';
import HOST_CV_AND_ENV_KEY from './HostContentViewConstants';
import { getHostDetails } from '../../HostDetailsActions';
import { useRexJobPolling } from '../../Tabs/RemoteExecutionHooks';
import './AssignHostCVModal.scss';
import { selectEnvironmentPaths } from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathSelectors';
import { OrderableAssignmentList, ExistingAssignmentShape } from './OrderableAssignments';

const ENV_PATH_OPTIONS = { key: ENVIRONMENT_PATHS_KEY };

const AddAnotherCVButton = ({ onClick, isDisabled }) => (
  <>
    <hr style={{ margin: '1rem 0' }} />
    <Button
      variant="link"
      icon={<PlusCircleIcon />}
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

const AssignHostCVModal = ({
  isOpen,
  closeModal,
  orgId,
  hostId,
  contentSourceId,
  hostName,
  existingAssignments,
  allowMultipleContentViews,
}) => {
  const [assignments, setAssignments] = useState([]);
  const initialAssignmentsRef = useRef(null);
  const [forceProfileUpload, setForceProfileUpload] = useState(false);
  const dispatch = useDispatch();

  const environmentPathResponse = useSelector(selectEnvironmentPaths);
  const environments = environmentPathResponse?.results
    ?.map(path => path.environments)
    .flat();
  const hostUpdateStatus = useSelector(state =>
    selectAPIStatus(state, HOST_CV_AND_ENV_KEY));

  const pathsUrl = `/organizations/${orgId}/environments/paths?permission_type=promotable${contentSourceId ? `&content_source_id=${contentSourceId}` : ''}`;
  useAPI(isOpen ? 'get' : null, api.getApiUrl(pathsUrl), ENV_PATH_OPTIONS);

  const handleModalClose = () => {
    setForceProfileUpload(false);
    setAssignments([]);
    initialAssignmentsRef.current = null;
    closeModal();
  };

  const handleAssignmentsChange = useCallback((newAssignments) => {
    setAssignments(newAssignments);
    // Store initial assignments on first change (when modal opens)
    if (initialAssignmentsRef.current === null && newAssignments.length > 0) {
      initialAssignmentsRef.current = newAssignments;
    }
  }, []);

  // Helper to normalize assignments for comparison
  const normalizeAssignment = a => ({
    cvName: a.selectedCV || a.contentView?.name,
    envId: a.selectedEnv?.[0]?.id || a.environment?.id,
  });

  // Check if assignments have changed from initial state
  const hasChanges = () => {
    if (!initialAssignmentsRef.current) return false;
    if (assignments.length !== initialAssignmentsRef.current.length) return true;

    const currentNormalized = assignments.map(normalizeAssignment);
    const initialNormalized = initialAssignmentsRef.current.map(normalizeAssignment);

    return !currentNormalized.every((curr, idx) => {
      const init = initialNormalized[idx];
      return curr.cvName === init.cvName && curr.envId === init.envId;
    });
  };

  const canSave =
    assignments.every(a => a.selectedCV && a.selectedEnv.length > 0) &&
    assignments.length > 0 &&
    hasChanges();

  const { triggerJobStart } = useRexJobPolling(runSubmanRepos, () =>
    getHostDetails({ hostname: hostName }));

  const refreshHostDetails = () => {
    if (forceProfileUpload) {
      triggerJobStart(hostName);
    }
    handleModalClose();
    return dispatch(getHostDetails({ hostname: hostName }));
  };

  const handleSave = () => {
    // Build array of content view environment labels for all assignments
    // Use the existing CVE label if available (for existing assignments),
    // otherwise construct it from env/cv labels (for new assignments)
    const cveLabels = assignments.map((a) => {
      // If this assignment has an existing CVE with a label, use it
      if (a.cveLabel) {
        return a.cveLabel;
      }

      // Otherwise, construct the label for new assignments
      const env = a.selectedEnv?.[0];
      const cv = a.contentView;

      if (env?.label && cv?.label) {
        const envLabel = env.label;
        const cvLabel = cv.label;

        // ContentViewEnvironment label format matches backend logic:
        // - For default CV in Library lce: just "Library"
        // - For default CV in non-Library lce: "Production/Default Organization View"
        // - For non-default CV: "lce_label/content_view_label"
        const isLibraryEnv = env.lifecycle_environment_library || env.library;
        const isDefaultCV = cv.content_view_default || cv.default;
        return isDefaultCV && isLibraryEnv ? envLabel : `${envLabel}/${cvLabel}`;
      }
      return null;
    }).filter(Boolean); // Remove any null entries

    const requestBody = {
      id: hostId,
      host: {
        content_facet_attributes: {
          content_view_environments: cveLabels,
        },
      },
    };

    dispatch(assignHostCVEnvironments(
      requestBody,
      hostId,
      refreshHostDetails,
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
      isLoading={hostUpdateStatus === STATUS.PENDING}
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
      title={allowMultipleContentViews
        ? __('Assign content view environments')
        : __('Edit content view environment')}
      width="50%"
      position="top"
      actions={modalActions}
      id="assign-cv-modal"
      ouiaId="assign-cv-modal"
    >
      <TextContent style={{ marginBottom: '1rem' }}>
        <Text component={TextVariants.p} ouiaId="modal-description">
          {allowMultipleContentViews
            ? __('A content view environment is a combination of a particular lifecycle environment and content view. Select content view environments to assign to this host. You can assign multiple content view environments to provide access to different sets of content.')
            : __('A content view environment is a combination of a particular lifecycle environment and content view. Select a content view environment to assign to this host.')}
        </Text>
      </TextContent>

      {environments?.some(env => env?.content_source?.environment_is_associated === false) && (
        <Alert
          variant="info"
          ouiaId="disabled-environments-alert"
          isInline
          title={__("Some lifecycle environments are disabled because they are not associated with the host's content source.")}
          style={{ marginBottom: '1rem' }}
        >
          {__("To enable them, add the lifecycle environment to the host's content source, or ")}
          <a href={`/change_host_content_source?host_id=${hostId}`}>
            {__("change the host's content source.")}
          </a>
        </Alert>
      )}

      <div className="attached-content-views">
        {allowMultipleContentViews && (
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
          assignmentStatus={hostUpdateStatus}
          onAssignmentsChange={handleAssignmentsChange}
          allowMultipleContentViews={allowMultipleContentViews}
          renderAddButton={allowMultipleContentViews ? (addFn, canAdd) => (
            <AddAnotherCVButton onClick={addFn} isDisabled={!canAdd} />
          ) : null}
        />
      </div>

      <hr style={{ margin: '1.5rem 0' }} />

      <TextContent>
        <Text component={TextVariants.small} ouiaId="force-profile-upload-text">
          {forceProfileUpload
            ? __('Errata and package information will be updated immediately.')
            : __('Errata and package information will be updated at the next host check-in or package action.')}
        </Text>
      </TextContent>
      <Checkbox
        isChecked={forceProfileUpload}
        onChange={(_event, val) => setForceProfileUpload(val)}
        label={__('Update the host immediately via remote execution')}
        id="force-profile-upload-checkbox"
        ouiaId="force-profile-upload-checkbox"
      />
    </Modal>
  );
};

AssignHostCVModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  orgId: PropTypes.number.isRequired,
  hostId: PropTypes.number.isRequired,
  contentSourceId: PropTypes.number,
  hostName: PropTypes.string.isRequired,
  existingAssignments: PropTypes.arrayOf(ExistingAssignmentShape),
  allowMultipleContentViews: PropTypes.bool.isRequired,
};

AssignHostCVModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  contentSourceId: null,
  existingAssignments: [],
};

export default AssignHostCVModal;
