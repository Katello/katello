import React, { useState, useEffect, useRef } from 'react';
import PropTypes from 'prop-types';
import { useSelector, useDispatch } from 'react-redux';
import { DndProvider } from 'react-dnd';
import { HTML5Backend } from 'react-dnd-html5-backend';
import {
  Alert,
  Button,
  ExpandableSection,
  Label,
  Tooltip,
} from '@patternfly/react-core';
import { MinusCircleIcon, GripVerticalIcon } from '@patternfly/react-icons';
import { FormattedMessage } from 'react-intl';
import { translate as __ } from 'foremanReact/common/I18n';
import { orderable } from 'foremanReact/components/common/forms/OrderableSelect/helpers';
import { STATUS } from 'foremanReact/constants';
import SkeletonLoader from 'foremanReact/components/common/SkeletonLoader';
import EnvironmentPaths from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPaths';
import { selectContentViews, selectContentViewStatus } from '../../../../../scenes/ContentViews/ContentViewSelectors';
import { selectEnvironmentPaths } from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathSelectors';
import ContentViewSelect from '../../../../../scenes/ContentViews/components/ContentViewSelect/ContentViewSelect';
import ContentViewSelectOption, { relevantVersionObjFromCv }
  from '../../../../../scenes/ContentViews/components/ContentViewSelect/ContentViewSelectOption';
import { getCVPlaceholderText } from '../../../../../scenes/ContentViews/components/ContentViewSelect/helpers';
import getContentViews from '../../../../../scenes/ContentViews/ContentViewsActions';
import { ContentViewEnvironmentDisplay } from './ContentViewDetailsCard';

// Shared PropTypes shapes for type safety
const EnvironmentShape = PropTypes.shape({
  id: PropTypes.number.isRequired,
  name: PropTypes.string,
  label: PropTypes.string,
  lifecycle_environment_library: PropTypes.bool,
  library: PropTypes.bool,
});

const ContentViewShape = PropTypes.shape({
  id: PropTypes.number.isRequired,
  name: PropTypes.string,
  label: PropTypes.string,
  composite: PropTypes.bool,
  content_view_default: PropTypes.bool,
  default: PropTypes.bool,
  rolling: PropTypes.bool,
});

const AssignmentShape = PropTypes.shape({
  id: PropTypes.string.isRequired,
  contentView: ContentViewShape,
  environment: EnvironmentShape,
  cveLabel: PropTypes.string,
  isExpanded: PropTypes.bool,
  cvSelectOpen: PropTypes.bool,
  selectedEnv: PropTypes.arrayOf(EnvironmentShape),
  selectedCV: PropTypes.string,
});

// Shape for existing assignments passed from parent (from API)
const ExistingAssignmentShape = PropTypes.shape({
  contentView: ContentViewShape,
  environment: EnvironmentShape,
  cveLabel: PropTypes.string,
  label: PropTypes.string, // Optional pre-computed label for the assignment
});

const AssignmentSection = ({
  assignment,
  index,
  assignments,
  onRemove,
  onEnvSelect,
  onCVSelect,
  onToggleExpanded,
  onToggleCVSelect,
  assignmentStatus,
  isDragging,
  allowMultipleContentViews,
  allowZeroAssignments,
}) => {
  const contentViewsResponse = useSelector(state =>
    selectContentViews(state, `FOR_ENV_${assignment.id}`));
  const contentViewsStatus = useSelector(state =>
    selectContentViewStatus(state, `FOR_ENV_${assignment.id}`));
  const { results: contentViewsInEnv = [] } = contentViewsResponse;

  // Filter out content views that are already assigned to other assignments
  // in the same lifecycle environment
  const assignedCVsInSameEnv = assignments
    .filter(a =>
      a.id !== assignment.id &&
      a.contentView?.id &&
      a.environment?.id &&
      assignment.selectedEnv.length > 0 &&
      a.environment.id === assignment.selectedEnv[0]?.id)
    .map(a => a.contentView.id);
  const availableContentViews = contentViewsInEnv.filter(cv =>
    !assignedCVsInSameEnv.includes(cv.id));

  const cvPlaceholderText = getCVPlaceholderText({
    environments: assignment.selectedEnv,
    cvSelectOptions: availableContentViews,
    contentViewsStatus,
  });

  const stillLoading = contentViewsStatus === STATUS.PENDING ||
    assignmentStatus === STATUS.PENDING;
  const noContentViewsAvailable = availableContentViews.length === 0 ||
    assignment.selectedEnv.length === 0;

  const toggleContent = assignment.contentView && assignment.selectedEnv.length > 0 ? (
    <ContentViewEnvironmentDisplay
      contentView={assignment.contentView}
      lifecycleEnvironment={assignment.selectedEnv[0]}
    />
  ) : (
    <div className="assignment-toggle">
      {assignment.selectedEnv.length > 0 && (
        <Tooltip
          position="top"
          enableFlip
          entryDelay={400}
          content={<FormattedMessage
            id="assignment-lce-tooltip"
            defaultMessage={__('Lifecycle environment: {lce}')}
            values={{
              lce: assignment.selectedEnv[0].name,
            }}
          />}
        >
          <Label
            color="purple"
            href={`/lifecycle_environments/${assignment.selectedEnv[0].id}`}
            style={{ marginRight: '2px' }}
          >
            {assignment.selectedEnv[0].name}
          </Label>
        </Tooltip>
      )}
      <span className="assignment-name">
        {__('Select a content view')}
      </span>
    </div>
  );

  return (
    <div className="assignment-section" style={isDragging ? { opacity: 0.5 } : {}}>
      <div className="assignment-header">
        <GripVerticalIcon className="drag-handle" />
        <ExpandableSection
          toggleContent={toggleContent}
          onToggle={onToggleExpanded}
          isExpanded={assignment.isExpanded}
          isIndented
        >
          <div className="assignment-content">
            <div className="environment-paths-wrapper">
              <EnvironmentPaths
                userCheckedItems={assignment.selectedEnv}
                setUserCheckedItems={onEnvSelect}
                publishing={false}
                multiSelect={false}
                headerText={__('Select a lifecycle environment')}
                isDisabled={assignmentStatus === STATUS.PENDING}
              />
            </div>

            <ContentViewSelect
              selections={assignment.selectedCV}
              onClear={() => onCVSelect(null, null, null)}
              onSelect={(event, selection) => {
                const selectedCVObj = availableContentViews.find(cv => cv.name === selection);
                onCVSelect(event, selection, selectedCVObj);
              }}
              isOpen={assignment.cvSelectOpen}
              isDisabled={stillLoading || noContentViewsAvailable}
              onToggle={onToggleCVSelect}
              placeholderText={cvPlaceholderText}
            >
              {(availableContentViews.length !== 0 && assignment.selectedEnv.length !== 0) &&
              availableContentViews?.map(cv => (
                <ContentViewSelectOption
                  key={cv.id}
                  value={cv.name}
                  cv={cv}
                  env={assignment.selectedEnv[0]}
                />
              ))}
            </ContentViewSelect>

            {contentViewsStatus === STATUS.RESOLVED &&
            assignment.selectedEnv.length > 0 &&
            availableContentViews.length === 0 && (
              <Alert
                ouiaId="no-cv-alert"
                variant="warning"
                isInline
                title={contentViewsInEnv.length === 0
                  ? __('No content views available for the selected lifecycle environment')
                  : __('All content views in this lifecycle environment are already assigned')}
                style={{ marginTop: '1rem' }}
              >
                {contentViewsInEnv.length === 0 ? (
                  <>
                    <a href="/content_views">{__('View the Content Views page')}</a>
                    {__(' to manage and promote content views, or select a different lifecycle environment.')}
                  </>
                ) : (
                  __('Please select a different lifecycle environment or remove an existing assignment.')
                )}
              </Alert>
            )}
          </div>
        </ExpandableSection>
      </div>

      {(allowMultipleContentViews || assignments.length > 1 || allowZeroAssignments) && (
        <div className="assignment-controls">
          <Button
            variant="link"
            icon={<MinusCircleIcon />}
            onClick={onRemove}
            className="remove-assignment-button"
            ouiaId={`remove-assignment-${index}`}
          >
            {__('Remove')}
          </Button>
        </div>
      )}
    </div>
  );
};

AssignmentSection.propTypes = {
  assignment: AssignmentShape.isRequired,
  index: PropTypes.number.isRequired,
  assignments: PropTypes.arrayOf(AssignmentShape).isRequired,
  onRemove: PropTypes.func.isRequired,
  onEnvSelect: PropTypes.func.isRequired,
  onCVSelect: PropTypes.func.isRequired,
  onToggleExpanded: PropTypes.func.isRequired,
  onToggleCVSelect: PropTypes.func.isRequired,
  assignmentStatus: PropTypes.string,
  isDragging: PropTypes.bool,
  allowMultipleContentViews: PropTypes.bool.isRequired,
  allowZeroAssignments: PropTypes.bool,
};

AssignmentSection.defaultProps = {
  assignmentStatus: undefined,
  isDragging: false,
  allowZeroAssignments: false,
};

// Create draggable version of AssignmentSection
const orderConfig = {
  type: 'assignment',
  direction: 'vertical',
  getItem: props => ({ id: props.assignment.id }),
  getIndex: props => props.index,
  getMoveFnc: props => props.moveAssignment,
};

const DraggableAssignmentSection = orderable(AssignmentSection, orderConfig);

// OrderableAssignmentList component that manages assignments state
export const OrderableAssignmentList = ({
  existingAssignments,
  isOpen,
  assignmentStatus,
  onAssignmentsChange,
  renderAddButton,
  allowMultipleContentViews,
  allowZeroAssignments,
}) => {
  const [assignments, setAssignments] = useState([]);
  const [initializationStatus, setInitializationStatus] = useState(STATUS.PENDING);
  const hasInitialized = useRef(false);
  const nextIdRef = useRef(0);
  const dispatch = useDispatch();
  const environmentPathResponse = useSelector(selectEnvironmentPaths);
  const { results: environmentPaths = [] } = environmentPathResponse || {};

  // Initialize assignments only when modal opens (not when existingAssignments changes)
  useEffect(() => {
    if (!isOpen) {
      setAssignments([]);
      setInitializationStatus(STATUS.PENDING);
      hasInitialized.current = false;
      nextIdRef.current = 0;
      return;
    }

    // Wait for environment paths to load before initializing
    if (!environmentPaths || environmentPaths.length === 0) {
      return;
    }

    // Only initialize if we haven't already
    if (hasInitialized.current) return;
    hasInitialized.current = true;

    if (existingAssignments && existingAssignments.length > 0) {
      // Collapse by default if there are 2 or more assignments
      const shouldCollapseByDefault = existingAssignments.length >= 2;
      const initialAssignments = existingAssignments.map((assignment, index) => ({
        id: `existing-${index}`,
        contentView: assignment.contentView,
        environment: assignment.environment,
        cveLabel: assignment.cveLabel, // Preserve the CVE label from API
        isExpanded: !shouldCollapseByDefault,
        cvSelectOpen: false,
        selectedEnv: assignment.environment ? [assignment.environment] : [],
        selectedCV: assignment.contentView?.name || null,
        label: assignment.label, // Preserve pre-computed label for existing assignments
      }));
      setAssignments(initialAssignments);

      // Fetch content views for each existing assignment's environment
      initialAssignments.forEach((assignment) => {
        if (assignment.environment?.id) {
          dispatch(getContentViews({
            environment_id: assignment.environment.id,
            include_default: true,
            full_result: true,
            order: 'default DESC',
          }, `FOR_ENV_${assignment.id}`));
        }
      });
      setInitializationStatus(STATUS.RESOLVED);
    } else {
      // Find the Library environment to pre-select it
      const libraryEnv = environmentPaths
        .flatMap(path => path.environments)
        .find(env => env.library);

      // Add new assignment inline with Library pre-selected if available
      nextIdRef.current += 1;
      const newAssignment = {
        id: `new-${nextIdRef.current}`,
        contentView: null,
        environment: libraryEnv || null,
        isExpanded: true,
        cvSelectOpen: false,
        selectedEnv: libraryEnv ? [libraryEnv] : [],
        selectedCV: null,
      };
      setAssignments([newAssignment]);

      // If Library was selected, fetch its content views
      if (libraryEnv) {
        dispatch(getContentViews({
          environment_id: libraryEnv.id,
          include_default: true,
          full_result: true,
          order: 'default DESC',
        }, `FOR_ENV_${newAssignment.id}`));
      }
      setInitializationStatus(STATUS.RESOLVED);
    }
  }, [isOpen, existingAssignments, environmentPaths, dispatch]);

  // Notify parent of assignment changes after state updates
  const prevAssignmentsRef = useRef(null);
  useEffect(() => {
    // Only notify if assignments have actually changed (not on initial mount)
    if (hasInitialized.current && prevAssignmentsRef.current !== assignments) {
      onAssignmentsChange(assignments);
      prevAssignmentsRef.current = assignments;
    }
  }, [assignments, onAssignmentsChange]);

  const addNewAssignment = () => {
    nextIdRef.current += 1;
    const newAssignment = {
      id: `new-${nextIdRef.current}`,
      contentView: null,
      environment: null,
      isExpanded: true,
      cvSelectOpen: false,
      selectedEnv: [],
      selectedCV: null,
    };
    setAssignments(prev => [
      ...prev.map(a => ({ ...a, isExpanded: false })),
      newAssignment,
    ]);
  };

  const canAddAnother = assignments.every(a => a.selectedCV && a.selectedEnv.length > 0) &&
                         (allowMultipleContentViews || assignments.length === 0);

  const removeAssignment = (assignmentId) => {
    setAssignments(prev => prev.filter(a => a.id !== assignmentId));
  };

  const moveAssignment = (dragIndex, hoverIndex) => {
    setAssignments((prev) => {
      const draggedAssignment = prev[dragIndex];
      const newAssignments = [...prev];
      newAssignments.splice(dragIndex, 1);
      newAssignments.splice(hoverIndex, 0, draggedAssignment);
      return newAssignments;
    });
  };

  const updateAssignment = (assignmentId, updates) => {
    setAssignments(prev =>
      prev.map(a => (a.id === assignmentId ? { ...a, ...updates } : a)));
  };

  const handleToggleExpanded = (assignmentId, isExpanded) => {
    updateAssignment(assignmentId, { isExpanded });
  };

  const handleToggleCVSelect = (assignmentId, cvSelectOpen) => {
    updateAssignment(assignmentId, { cvSelectOpen });
  };

  const handleEnvSelect = (assignmentId, selection) => {
    if (selection[0]) {
      dispatch(getContentViews({
        environment_id: selection[0].id,
        include_default: true,
        full_result: true,
        order: 'default DESC',
      }, `FOR_ENV_${assignmentId}`));
    }
    updateAssignment(assignmentId, {
      selectedEnv: selection,
      selectedCV: null,
      environment: selection[0] || null,
      contentView: null,
      label: null, // Clear pre-computed label when environment changes
    });
  };

  const handleCVSelect = (assignmentId, _event, selection, selectedCVObj) => {
    let contentViewWithVersion = selectedCVObj;

    if (selectedCVObj) {
      // Get the selected environment for this assignment
      const selectedAssignment = assignments.find(a => a.id === assignmentId);
      const selectedEnv = selectedAssignment?.selectedEnv?.[0];

      if (selectedEnv && selectedCVObj.versions) {
        // Find the version that's in this specific environment
        const versionInEnv = relevantVersionObjFromCv(selectedCVObj, selectedEnv);

        if (versionInEnv) {
          contentViewWithVersion = {
            ...selectedCVObj,
            content_view_version: versionInEnv.version,
            content_view_version_id: versionInEnv.id,
            content_view_version_latest: versionInEnv.version === selectedCVObj.latest_version,
            content_view_default: selectedCVObj.default,
          };
        }
      }
    }

    updateAssignment(assignmentId, {
      selectedCV: selection,
      cvSelectOpen: false,
      contentView: contentViewWithVersion,
      label: null, // Clear pre-computed label when CV changes
    });
  };

  return (
    <SkeletonLoader
      status={initializationStatus}
      skeletonProps={{ count: 3, height: 60 }}
    >
      <DndProvider backend={HTML5Backend}>
        {assignments.map((assignment, index) => (
          <DraggableAssignmentSection
            key={assignment.id}
            assignment={assignment}
            index={index}
            assignments={assignments}
            onRemove={() => removeAssignment(assignment.id)}
            moveAssignment={moveAssignment}
            onEnvSelect={selection => handleEnvSelect(assignment.id, selection)}
            onCVSelect={(event, selection, selectedCVObj) =>
              handleCVSelect(assignment.id, event, selection, selectedCVObj)}
            onToggleExpanded={() =>
              handleToggleExpanded(assignment.id, !assignment.isExpanded)}
            onToggleCVSelect={() =>
              handleToggleCVSelect(assignment.id, !assignment.cvSelectOpen)}
            assignmentStatus={assignmentStatus}
            allowMultipleContentViews={allowMultipleContentViews}
            allowZeroAssignments={allowZeroAssignments}
          />
        ))}
      </DndProvider>

      {renderAddButton && renderAddButton(addNewAssignment, canAddAnother)}
    </SkeletonLoader>
  );
};

OrderableAssignmentList.propTypes = {
  existingAssignments: PropTypes.arrayOf(ExistingAssignmentShape),
  isOpen: PropTypes.bool.isRequired,
  assignmentStatus: PropTypes.string,
  onAssignmentsChange: PropTypes.func.isRequired,
  renderAddButton: PropTypes.func,
  allowMultipleContentViews: PropTypes.bool.isRequired,
  allowZeroAssignments: PropTypes.bool,
};

OrderableAssignmentList.defaultProps = {
  existingAssignments: [],
  assignmentStatus: undefined,
  renderAddButton: null,
  allowZeroAssignments: false,
};

export default DraggableAssignmentSection;
export { ExistingAssignmentShape };
