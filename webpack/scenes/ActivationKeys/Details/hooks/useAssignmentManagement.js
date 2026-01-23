import { useState } from 'react';

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
