import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { FormGroup, Button, Badge } from '@patternfly/react-core';
import { PlusCircleIcon } from '@patternfly/react-icons';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import { STATUS } from 'foremanReact/constants';
import api, { orgId } from '../../../../services/api';
import { ENVIRONMENT_PATHS_KEY } from '../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathConstants';
import { OrderableAssignmentList } from '../../../../components/extensions/HostDetails/Cards/ContentViewDetailsCard/OrderableAssignments';

const ENV_PATH_OPTIONS = { key: ENVIRONMENT_PATHS_KEY };

const MultiCVEnvForm = ({
  organizationId,
  contentSourceId,
  assignmentCount,
  onAssignmentsChange,
  allowMultipleContentViews,
  isLoading,
}) => {
  // Fetch environment paths filtered by content source
  // Use organizationId prop if available, otherwise fall back to orgId() service
  const orgIdToUse = organizationId || orgId();
  const pathsUrl = `/organizations/${orgIdToUse}/environments/paths?permission_type=promotable${contentSourceId ? `&content_source_id=${contentSourceId}` : ''}`;
  useAPI('get', api.getApiUrl(pathsUrl), ENV_PATH_OPTIONS);

  const renderAddButton = (addNewAssignment, canAddAnother) => (
    allowMultipleContentViews && (
      <>
        <hr style={{ margin: '1rem 0' }} />
        <Button
          variant="link"
          icon={<PlusCircleIcon />}
          onClick={addNewAssignment}
          isDisabled={!canAddAnother || isLoading}
          ouiaId="add-cvenv-button"
        >
          {__('Add content view environment')}
        </Button>
      </>
    )
  );

  return (
    <FormGroup
      label={
        assignmentCount > 0 ? (
          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            <span>{__('Content view environments')}</span>
            <Badge isRead>{assignmentCount}</Badge>
          </div>
        ) : __('Content view environments')
      }
      isRequired={assignmentCount === 0}
      fieldId="content-view-environments"
    >
      <OrderableAssignmentList
        existingAssignments={[]} // Start blank per user requirement
        isOpen
        assignmentStatus={isLoading ? STATUS.PENDING : undefined}
        onAssignmentsChange={onAssignmentsChange}
        allowMultipleContentViews={allowMultipleContentViews}
        renderAddButton={renderAddButton}
        organizationId={organizationId}
        contentSourceId={contentSourceId}
        key={contentSourceId} // Force re-mount when content source changes
      />
    </FormGroup>
  );
};

MultiCVEnvForm.propTypes = {
  organizationId: PropTypes.number,
  contentSourceId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  assignmentCount: PropTypes.number,
  onAssignmentsChange: PropTypes.func.isRequired,
  allowMultipleContentViews: PropTypes.bool,
  isLoading: PropTypes.bool,
};

MultiCVEnvForm.defaultProps = {
  organizationId: null,
  contentSourceId: null,
  assignmentCount: 0,
  allowMultipleContentViews: false,
  isLoading: false,
};

export default MultiCVEnvForm;
