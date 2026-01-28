import { renderHook, act } from '@testing-library/react-hooks';
import useAssignmentManagement, { constructCVELabel } from '../useAssignmentManagement';

describe('useAssignmentManagement', () => {
  describe('constructCVELabel', () => {
    it('returns label for default CV in Library', () => {
      const assignment = {
        selectedEnv: [{ label: 'Library', lifecycle_environment_library: true, library: true }],
        contentView: { label: 'Default_Organization_View', content_view_default: true, default: true },
      };

      expect(constructCVELabel(assignment)).toBe('Library');
    });

    it('returns label for custom CV in Library', () => {
      const assignment = {
        selectedEnv: [{ label: 'Library', lifecycle_environment_library: true, library: true }],
        contentView: { label: 'my_cv', content_view_default: false, default: false },
      };

      expect(constructCVELabel(assignment)).toBe('Library/my_cv');
    });

    it('returns label for any CV in non-Library environment', () => {
      const assignment = {
        selectedEnv: [{ label: 'Production', lifecycle_environment_library: false, library: false }],
        contentView: { label: 'my_cv', content_view_default: false, default: false },
      };

      expect(constructCVELabel(assignment)).toBe('Production/my_cv');
    });

    it('returns null when environment is missing', () => {
      const assignment = {
        selectedEnv: [],
        contentView: { label: 'my_cv', content_view_default: false, default: false },
      };

      expect(constructCVELabel(assignment)).toBeNull();
    });

    it('returns null when content view is missing', () => {
      const assignment = {
        selectedEnv: [{ label: 'Library', lifecycle_environment_library: true }],
        contentView: null,
      };

      expect(constructCVELabel(assignment)).toBeNull();
    });
  });

  describe('hasChanges detection', () => {
    it('detects no changes when nothing has changed', () => {
      const { result } = renderHook(() => useAssignmentManagement(true));

      // Simulate initial assignments
      const initialAssignments = [
        {
          id: '1',
          selectedEnv: [{ label: 'Library', lifecycle_environment_library: true, library: true }],
          contentView: { label: 'cv_1', content_view_default: false, default: false },
          selectedCV: 'cv_1',
        },
        {
          id: '2',
          selectedEnv: [{ label: 'dev', lifecycle_environment_library: false, library: false }],
          contentView: { label: 'cv_2', content_view_default: false, default: false },
          selectedCV: 'cv_2',
        },
      ];

      act(() => {
        result.current.handleAssignmentsChange(initialAssignments);
      });

      // No changes - canSave should be false
      expect(result.current.canSave).toBe(false);

      // Set same assignments again
      act(() => {
        result.current.handleAssignmentsChange(initialAssignments);
      });

      expect(result.current.canSave).toBe(false);
    });

    it('detects changes when an assignment is removed', () => {
      const { result } = renderHook(() => useAssignmentManagement(true));

      const initialAssignments = [
        {
          id: '1',
          selectedEnv: [{ label: 'Library', lifecycle_environment_library: true, library: true }],
          contentView: { label: 'cv_1', content_view_default: false, default: false },
          selectedCV: 'cv_1',
        },
        {
          id: '2',
          selectedEnv: [{ label: 'dev', lifecycle_environment_library: false, library: false }],
          contentView: { label: 'cv_2', content_view_default: false, default: false },
          selectedCV: 'cv_2',
        },
      ];

      act(() => {
        result.current.handleAssignmentsChange(initialAssignments);
      });

      // Remove one assignment
      act(() => {
        result.current.handleAssignmentsChange([initialAssignments[0]]);
      });

      expect(result.current.canSave).toBe(true);
    });

    it('detects changes when an assignment is added', () => {
      const { result } = renderHook(() => useAssignmentManagement(true));

      const initialAssignments = [
        {
          id: '1',
          selectedEnv: [{ label: 'Library', lifecycle_environment_library: true, library: true }],
          contentView: { label: 'cv_1', content_view_default: false, default: false },
          selectedCV: 'cv_1',
        },
      ];

      act(() => {
        result.current.handleAssignmentsChange(initialAssignments);
      });

      // Add another assignment
      const newAssignments = [
        ...initialAssignments,
        {
          id: '2',
          selectedEnv: [{ label: 'dev', lifecycle_environment_library: false, library: false }],
          contentView: { label: 'cv_2', content_view_default: false, default: false },
          selectedCV: 'cv_2',
        },
      ];

      act(() => {
        result.current.handleAssignmentsChange(newAssignments);
      });

      expect(result.current.canSave).toBe(true);
    });

    it('detects changes when assignments are reordered', () => {
      const { result } = renderHook(() => useAssignmentManagement(true));

      const initialAssignments = [
        {
          id: '1',
          selectedEnv: [{ label: 'Library', lifecycle_environment_library: true, library: true }],
          contentView: { label: 'cv_1', content_view_default: false, default: false },
          selectedCV: 'cv_1',
        },
        {
          id: '2',
          selectedEnv: [{ label: 'dev', lifecycle_environment_library: false, library: false }],
          contentView: { label: 'cv_2', content_view_default: false, default: false },
          selectedCV: 'cv_2',
        },
      ];

      act(() => {
        result.current.handleAssignmentsChange(initialAssignments);
      });

      // Reorder assignments
      const reorderedAssignments = [initialAssignments[1], initialAssignments[0]];

      act(() => {
        result.current.handleAssignmentsChange(reorderedAssignments);
      });

      // Should detect the reorder as a change
      expect(result.current.canSave).toBe(true);
    });

    it('detects changes when CV is changed in an assignment', () => {
      const { result } = renderHook(() => useAssignmentManagement(true));

      const initialAssignments = [
        {
          id: '1',
          selectedEnv: [{ label: 'Library', lifecycle_environment_library: true, library: true }],
          contentView: { label: 'cv_1', content_view_default: false, default: false },
          selectedCV: 'cv_1',
        },
      ];

      act(() => {
        result.current.handleAssignmentsChange(initialAssignments);
      });

      // Change the content view
      const changedAssignments = [
        {
          id: '1',
          selectedEnv: [{ label: 'Library', lifecycle_environment_library: true, library: true }],
          contentView: { label: 'cv_2', content_view_default: false, default: false },
          selectedCV: 'cv_2',
        },
      ];

      act(() => {
        result.current.handleAssignmentsChange(changedAssignments);
      });

      expect(result.current.canSave).toBe(true);
    });

    it('detects changes when environment is changed in an assignment', () => {
      const { result } = renderHook(() => useAssignmentManagement(true));

      const initialAssignments = [
        {
          id: '1',
          selectedEnv: [{ label: 'Library', lifecycle_environment_library: true, library: true }],
          contentView: { label: 'cv_1', content_view_default: false, default: false },
          selectedCV: 'cv_1',
        },
      ];

      act(() => {
        result.current.handleAssignmentsChange(initialAssignments);
      });

      // Change the environment
      const changedAssignments = [
        {
          id: '1',
          selectedEnv: [{ label: 'dev', lifecycle_environment_library: false, library: false }],
          contentView: { label: 'cv_1', content_view_default: false, default: false },
          selectedCV: 'cv_1',
        },
      ];

      act(() => {
        result.current.handleAssignmentsChange(changedAssignments);
      });

      expect(result.current.canSave).toBe(true);
    });
  });

  describe('canSave validation', () => {
    it('requires all assignments to be complete', () => {
      const { result } = renderHook(() => useAssignmentManagement(true));

      // Incomplete assignment (missing content view)
      const incompleteAssignments = [
        {
          id: '1',
          selectedEnv: [{ label: 'Library', lifecycle_environment_library: true, library: true }],
          contentView: null,
          selectedCV: null,
        },
      ];

      act(() => {
        result.current.handleAssignmentsChange(incompleteAssignments);
      });

      // Even if there's a "change" from initial state, incomplete assignments prevent save
      expect(result.current.canSave).toBe(false);
    });

    it('enforces single assignment when allowMultipleContentViews is false', () => {
      const { result } = renderHook(() => useAssignmentManagement(false));

      const initialAssignments = [
        {
          id: '1',
          selectedEnv: [{ label: 'Library', lifecycle_environment_library: true, library: true }],
          contentView: { label: 'cv_1', content_view_default: false, default: false },
          selectedCV: 'cv_1',
        },
      ];

      act(() => {
        result.current.handleAssignmentsChange(initialAssignments);
      });

      // Add another assignment (not allowed when allowMultipleContentViews is false)
      const multipleAssignments = [
        ...initialAssignments,
        {
          id: '2',
          selectedEnv: [{ label: 'dev', lifecycle_environment_library: false, library: false }],
          contentView: { label: 'cv_2', content_view_default: false, default: false },
          selectedCV: 'cv_2',
        },
      ];

      act(() => {
        result.current.handleAssignmentsChange(multipleAssignments);
      });

      // Should not be able to save with 2 assignments
      expect(result.current.canSave).toBe(false);
    });

    it('allows multiple assignments when allowMultipleContentViews is true', () => {
      const { result } = renderHook(() => useAssignmentManagement(true));

      const initialAssignments = [
        {
          id: '1',
          selectedEnv: [{ label: 'Library', lifecycle_environment_library: true, library: true }],
          contentView: { label: 'cv_1', content_view_default: false, default: false },
          selectedCV: 'cv_1',
        },
      ];

      act(() => {
        result.current.handleAssignmentsChange(initialAssignments);
      });

      // Add another assignment (allowed when allowMultipleContentViews is true)
      const multipleAssignments = [
        ...initialAssignments,
        {
          id: '2',
          selectedEnv: [{ label: 'dev', lifecycle_environment_library: false, library: false }],
          contentView: { label: 'cv_2', content_view_default: false, default: false },
          selectedCV: 'cv_2',
        },
      ];

      act(() => {
        result.current.handleAssignmentsChange(multipleAssignments);
      });

      // Should be able to save with 2 assignments
      expect(result.current.canSave).toBe(true);
    });
  });

  describe('resetState', () => {
    it('clears assignments and initial state', () => {
      const { result } = renderHook(() => useAssignmentManagement(true));

      const assignments = [
        {
          id: '1',
          selectedEnv: [{ label: 'Library', lifecycle_environment_library: true, library: true }],
          contentView: { label: 'cv_1', content_view_default: false, default: false },
          selectedCV: 'cv_1',
        },
      ];

      act(() => {
        result.current.handleAssignmentsChange(assignments);
      });

      expect(result.current.assignments).toHaveLength(1);

      act(() => {
        result.current.resetState();
      });

      expect(result.current.assignments).toHaveLength(0);
      expect(result.current.canSave).toBe(false);
    });
  });
});
