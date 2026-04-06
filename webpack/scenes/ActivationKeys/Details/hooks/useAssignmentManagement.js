import { useState } from 'react';
import { buildContentViewEnvironmentLabel as constructCVELabel } from '../../../../utils/contentViewEnvironmentLabel';

// Re-export for backward compatibility
export { constructCVELabel };

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
