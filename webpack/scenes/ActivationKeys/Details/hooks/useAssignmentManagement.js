import { useState } from 'react';

/**
 * Constructs a content view environment label from an assignment
 * Returns null if the assignment doesn't have both environment and content view
 */
export const constructCVELabel = (assignment) => {
  const env = assignment.selectedEnv?.[0];
  const cv = assignment.contentView;

  if (!env || !cv) return null;

  // Get labels - support both camelCase and snake_case
  const envLabel = env.label || env.lifecycle_environment_label;
  const cvLabel = cv.label || cv.content_view_label;

  if (!envLabel || !cvLabel) return null;

  // Content view environment label format matches backend logic:
  // - Default CV in Library: "Library"
  // - Custom CV in Library: "Library/my_cv"
  // - Any CV in other envs: "Production/my_cv"
  const isLibraryEnv = env.lifecycle_environment_library || env.library;
  const isDefaultCV = cv.content_view_default || cv.default;

  return isDefaultCV && isLibraryEnv ? envLabel : `${envLabel}/${cvLabel}`;
};

/**
 * Custom hook for managing assignment state and validation in both
 * AssignAKCVModal and CreateAKCVModal
 */
const useAssignmentManagement = (allowMultipleContentViews) => {
  const [assignments, setAssignments] = useState([]);
  const [initialAssignments, setInitialAssignments] = useState([]);

  const handleAssignmentsChange = (newAssignments) => {
    setAssignments(newAssignments);
    // Store initial assignments on first change (when modal opens)
    if (initialAssignments.length === 0 && newAssignments.length > 0) {
      setInitialAssignments(newAssignments);
    }
  };

  const resetState = () => {
    setAssignments([]);
    setInitialAssignments([]);
  };

  // Check if assignments have changed from initial state
  const hasChanges = () => {
    if (assignments.length !== initialAssignments.length) return true;

    // Compare actual labels that will be sent to backend (order matters!)
    const currentLabels = assignments.map(constructCVELabel).filter(Boolean);
    const initialLabels = initialAssignments.map(constructCVELabel).filter(Boolean);

    if (currentLabels.length !== initialLabels.length) return true;

    return !currentLabels.every((label, idx) => label === initialLabels[idx]);
  };

  // Allow zero assignments for activation keys (unlike hosts)
  // When allowMultipleContentViews is false, only allow saving with 0 or 1 assignment
  const canSave =
    assignments.every(a => a.selectedCV && a.selectedEnv.length > 0) &&
    hasChanges() &&
    (allowMultipleContentViews || assignments.length <= 1);

  return {
    assignments,
    handleAssignmentsChange,
    resetState,
    canSave,
  };
};

export default useAssignmentManagement;
