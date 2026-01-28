import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import { Modal, Button, TextContent, Text, TextVariants } from '@patternfly/react-core';
import { PlusCircleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { foremanUrl } from 'foremanReact/common/helpers';
import { APIActions } from 'foremanReact/redux/API';
import { HOSTS_API_PATH, API_REQUEST_KEY } from 'foremanReact/routes/Hosts/constants';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import { selectAPIStatus } from 'foremanReact/redux/API/APISelectors';
import { ENVIRONMENT_PATHS_KEY } from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathConstants';
import api from '../../../../../services/api';
import { OrderableAssignmentList } from '../../../HostDetails/Cards/ContentViewDetailsCard/OrderableAssignments';
import { bulkAssignContentViewEnvironments } from './actions';
import './BulkAssignCVEnvsModal.scss';

const ENV_PATH_OPTIONS = { key: ENVIRONMENT_PATHS_KEY };
const BULK_ASSIGN_CVES_KEY = 'BULK_ASSIGN_CONTENT_VIEW_ENVIRONMENTS';

const BulkAssignCVEnvsModal = ({
  isOpen,
  closeModal,
  selectedCount,
  orgId,
  fetchBulkParams,
  allowMultipleContentViews,
}) => {
  const [assignments, setAssignments] = useState([]);
  const dispatch = useDispatch();
  const assignmentStatus = useSelector(state => selectAPIStatus(state, BULK_ASSIGN_CVES_KEY));

  const pathsUrl = `/organizations/${orgId}/environments/paths?permission_type=promotable`;
  useAPI(isOpen ? 'get' : null, api.getApiUrl(pathsUrl), ENV_PATH_OPTIONS);

  const handleModalClose = () => {
    setAssignments([]);
    closeModal();
  };

  const handleSuccess = () => {
    // Refresh the hosts table to show updated content view environments
    dispatch(APIActions.get({
      key: API_REQUEST_KEY,
      url: foremanUrl(HOSTS_API_PATH),
    }));
    handleModalClose();
  };

  const handleAssignmentsChange = (newAssignments) => {
    setAssignments(newAssignments);
  };

  const canSave = assignments.every(a => a.contentView && a.selectedEnv.length > 0) &&
                  assignments.length > 0;

  const handleSave = () => {
    // Build array of content view environment labels
    const cvEnvLabels = assignments.map((assignment) => {
      const env = assignment.selectedEnv[0];
      const cv = assignment.contentView;
      const envLabel = env.label;
      const cvLabel = cv.label;

      // ContentViewEnvironment label format matches backend logic:
      // - For default CV in Library: just "Library"
      // - For default CV in non-Library: "Production/Default_Organization_View"
      // - For non-default CV: "environment_label/content_view_label"
      const isLibraryEnv = env.lifecycle_environment_library || env.library;
      const isDefaultCV = cv.content_view_default || cv.default;
      return isDefaultCV && isLibraryEnv ? envLabel : `${envLabel}/${cvLabel}`;
    });

    const requestBody = {
      content_view_environments: cvEnvLabels,
      organization_id: orgId,
      included: {
        search: fetchBulkParams(),
      },
    };

    dispatch(bulkAssignContentViewEnvironments(
      requestBody,
      handleSuccess,
      handleModalClose,
    ));
  };

  const renderAddButton = (addNewAssignment, canAddAnother) => (
    <Button
      variant="link"
      icon={<PlusCircleIcon />}
      onClick={addNewAssignment}
      isDisabled={!canAddAnother || assignmentStatus === STATUS.PENDING}
      ouiaId="add-content-view-env-button"
    >
      {__('Add content view environment')}
    </Button>
  );

  const modalActions = [
    <Button
      key="save"
      ouiaId="bulk-assign-cves-modal-save-button"
      variant="primary"
      onClick={handleSave}
      isDisabled={!canSave || assignmentStatus === STATUS.PENDING}
      isLoading={assignmentStatus === STATUS.PENDING}
    >
      {__('Save')}
    </Button>,
    <Button
      key="cancel"
      ouiaId="bulk-assign-cves-modal-cancel-button"
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
        : __('Assign content view environment')}
      width="50%"
      position="top"
      actions={modalActions}
      id="bulk-assign-cves-modal"
      key="bulk-assign-cves-modal"
      ouiaId="bulk-assign-cves-modal"
    >
      <TextContent style={{ marginBottom: '1rem' }}>
        <Text component={TextVariants.p} ouiaId="bulk-assign-cves-description">
          <FormattedMessage
            defaultMessage={allowMultipleContentViews
              ? __('A content view environment is a combination of a particular lifecycle environment and content view. You can assign multiple content view environments to provide access to different sets of content. Your selection here will {replace} all existing content view environments on {hosts}.')
              : __('A content view environment is a combination of a particular lifecycle environment and content view. Your selection here will {replace} all existing content view environments on {hosts}.')}
            values={{
              replace: <strong>{__('replace')}</strong>,
              hosts: (
                <strong>
                  <FormattedMessage
                    defaultMessage="{count, plural, one {# {singular}} other {# {plural}}}"
                    values={{
                      count: selectedCount,
                      singular: __('selected host'),
                      plural: __('selected hosts'),
                    }}
                    id="bulk-assign-cves-count-i18n"
                  />
                </strong>
              ),
            }}
            id="bulk-assign-cves-description-i18n"
          />
        </Text>
      </TextContent>

      <OrderableAssignmentList
        existingAssignments={[]}
        isOpen={isOpen}
        assignmentStatus={assignmentStatus}
        onAssignmentsChange={handleAssignmentsChange}
        renderAddButton={allowMultipleContentViews ? renderAddButton : null}
        allowMultipleContentViews={allowMultipleContentViews}
      />

      <hr style={{ margin: '1.5rem 0' }} />

      <TextContent>
        <Text ouiaId="profile-upload-text">
          {__('Errata and package information will be updated at the next host check-in or package action.')}
        </Text>
      </TextContent>
    </Modal>
  );
};

BulkAssignCVEnvsModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  selectedCount: PropTypes.number.isRequired,
  orgId: PropTypes.number.isRequired,
  fetchBulkParams: PropTypes.func.isRequired,
  allowMultipleContentViews: PropTypes.bool,
};

BulkAssignCVEnvsModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  allowMultipleContentViews: true,
};

export default BulkAssignCVEnvsModal;
