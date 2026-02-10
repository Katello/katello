import React from 'react';
import { renderWithRedux, patientlyWaitFor, act } from 'react-testing-lib-wrapper';
import userEvent from '@testing-library/user-event';
import AssignHostCVModal from '../AssignHostCVModal';
import mockEnvPaths from './envPaths.fixtures.json';
import mockContentViews from './contentViews.fixtures.json';
import HOST_CV_AND_ENV_KEY from '../HostContentViewConstants';
import { assertNockRequest, nockInstance } from '../../../../../../test-utils/nockWrapper';
import katelloApi from '../../../../../../services/api';
import * as actions from '../HostContentViewActions';
import * as rexHooks from '../../../Tabs/RemoteExecutionHooks';
import * as hostDetailsActions from '../../../HostDetailsActions';

const contentViewsUrl = katelloApi.getApiUrl('/content_views');
const envPathsUrl = katelloApi.getApiUrl('/organizations/1/environments/paths');

const renderOptions = () => ({
  apiNamespace: HOST_CV_AND_ENV_KEY,
  initialState: {
    API: {
      ENVIRONMENT_PATHS: {
        response: mockEnvPaths,
        status: 'RESOLVED',
      },
    },
  },
});

let firstEnv;

const getCVQuery = envId => ({
  organization_id: 1,
  include_permissions: true,
  environment_id: envId,
  include_default: true,
  full_result: true,
  order: 'default DESC',
});

beforeEach(() => {
  const { results } = mockEnvPaths;
  const [firstEnvPath] = results;
  const { environments } = firstEnvPath;
  [firstEnv] = environments;
});

describe('AssignHostCVModal', () => {
  beforeEach(() => {
    // Mock the environment paths API call that happens in useAPI
    nockInstance
      .get(envPathsUrl)
      .query(true) // Match any query parameters
      .reply(200, mockEnvPaths);

    // Mock the automatic Library content views fetch that happens on modal open
    // The modal now pre-selects Library and fetches its content views automatically
    nockInstance
      .get(contentViewsUrl)
      .query(getCVQuery(firstEnv.id))
      .reply(200, mockContentViews)
      .persist(); // Allow multiple calls to this endpoint
  });

  test('Renders modal with correct title and description for multiple CVE mode', async () => {
    const { getByText } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getByText('Assign content view environments')).toBeInTheDocument();
      expect(getByText(/You can assign multiple content view environments/)).toBeInTheDocument();
    });
  });

  test('Renders modal with correct title and description for single CVE mode', async () => {
    const { getByText } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews={false}
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getByText('Edit content view environment')).toBeInTheDocument();
      expect(getByText(/Select a content view environment to assign to this host\./)).toBeInTheDocument();
    });
  });

  test('Displays environment paths in first assignment', async () => {
    const { getAllByText } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getAllByText(firstEnv.name)[0]).toBeInTheDocument();
    });
  });

  test('Starts with one empty assignment when no existing assignments', async () => {
    const { getByText } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getByText('Select a content view')).toBeInTheDocument();
    });
  });

  test('Select environment triggers CV API call', async () => {
    const contentViewsScope = nockInstance
      .get(contentViewsUrl)
      .query(getCVQuery(firstEnv.id))
      .reply(200, mockContentViews);

    const {
      getAllByRole,
    } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getAllByRole('radio', { name: firstEnv.name })[0]).toBeInTheDocument();
    });

    // Select environment
    const envRadio = getAllByRole('radio', { name: firstEnv.name })[0];
    await act(async () => {
      userEvent.click(envRadio);
    });

    // Wait and verify the CV API was called
    await patientlyWaitFor(() => {
      assertNockRequest(contentViewsScope);
    });
  });

  test('Add another content view button exists in multiple CVE mode', async () => {
    const {
      getByText,
    } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    // Verify "Assign another content view environment" button exists
    await patientlyWaitFor(() => {
      expect(getByText('Assign another content view environment')).toBeInTheDocument();
    });
  });

  test('Add another content view button does NOT exist in single CVE mode', async () => {
    const {
      queryByText,
    } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews={false}
      />,
      renderOptions(),
    );

    // Verify "Assign another content view environment" button does NOT exist
    await patientlyWaitFor(() => {
      expect(queryByText('Assign another content view environment')).not.toBeInTheDocument();
    });
  });

  test('Initializes with multiple existing assignments in multiple CVE mode', async () => {
    const existingAssignments = [
      {
        contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
        environment: { id: 1, name: 'Library', label: 'Library' },
      },
      {
        contentView: { id: 3, name: 'composite_cv', label: 'composite_cv' },
        environment: { id: 2, name: 'dev', label: 'dev' },
      },
    ];

    // Mock content views fetch for environment id 2 (dev) since it's not Library
    nockInstance
      .get(contentViewsUrl)
      .query(getCVQuery(2))
      .reply(200, mockContentViews);

    const { getByText, getAllByRole } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        existingAssignments={existingAssignments}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getByText('cv_1')).toBeInTheDocument();
      expect(getByText('composite_cv')).toBeInTheDocument();
      // Verify two remove buttons (one for each assignment)
      expect(getAllByRole('button', { name: 'Remove' })).toHaveLength(2);
    });
  });

  test('Can remove an assignment from existing assignments in multiple CVE mode', async () => {
    const existingAssignments = [
      {
        contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
        environment: { id: 1, name: 'Library', label: 'Library' },
      },
      {
        contentView: { id: 3, name: 'composite_cv', label: 'composite_cv' },
        environment: { id: 2, name: 'dev', label: 'dev' },
      },
    ];

    // Mock content views fetch for environment id 2 (dev) since it's not Library
    nockInstance
      .get(contentViewsUrl)
      .query(getCVQuery(2))
      .reply(200, mockContentViews);

    const {
      getAllByRole,
      queryByText,
    } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        existingAssignments={existingAssignments}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(queryByText('cv_1')).toBeInTheDocument();
      expect(queryByText('composite_cv')).toBeInTheDocument();
    });

    // Remove the first assignment
    const removeButtons = getAllByRole('button', { name: 'Remove' });
    expect(removeButtons).toHaveLength(2);

    await act(async () => {
      userEvent.click(removeButtons[0]);
    });

    // Verify only one assignment remains
    await patientlyWaitFor(() => {
      expect(getAllByRole('button', { name: 'Remove' })).toHaveLength(1);
      expect(queryByText('cv_1')).not.toBeInTheDocument();
      expect(queryByText('composite_cv')).toBeInTheDocument();
    });
  });

  test('Displays remove button for each assignment in multiple CVE mode', async () => {
    const { getAllByRole } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      // One assignment by default, so one remove button
      expect(getAllByRole('button', { name: 'Remove' })).toHaveLength(1);
    });
  });

  test('Does NOT display remove button in single CVE mode', async () => {
    const { queryByRole } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews={false}
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      // No remove button in single CVE mode
      expect(queryByRole('button', { name: 'Remove' })).not.toBeInTheDocument();
    });
  });

  test('Force profile upload checkbox toggles text', async () => {
    const { getByRole, getByText } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getByText(/Errata and package information will be updated at the next host check-in/)).toBeInTheDocument();
    });

    const checkbox = getByRole('checkbox', { name: 'Update the host immediately via remote execution' });

    await act(async () => {
      userEvent.click(checkbox);
    });

    await patientlyWaitFor(() => {
      expect(getByText(/Errata and package information will be updated immediately/)).toBeInTheDocument();
    });
  });

  test('Save button disabled when no CV selected', async () => {
    const { getAllByRole } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      expect(saveButton).toHaveAttribute('aria-disabled', 'true');
    });
  });

  test('Assignment sections are expandable', async () => {
    const { getByText } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getByText('Select a content view')).toBeInTheDocument();
      // Initially expanded, so env selection should be visible
      expect(getByText('Select a lifecycle environment')).toBeInTheDocument();
    });
  });

  test('Shows alert when environment not associated with content source', async () => {
    const modifiedEnvPaths = {
      ...mockEnvPaths,
      results: mockEnvPaths.results.map(path => ({
        ...path,
        environments: path.environments.map((env, idx) =>
          (idx === 0 ? env : {
            ...env,
            content_source: {
              environment_is_associated: false,
            },
          })),
      })),
    };

    const { getByText } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews
      />,
      {
        apiNamespace: HOST_CV_AND_ENV_KEY,
        initialState: {
          API: {
            ENVIRONMENT_PATHS: {
              response: modifiedEnvPaths,
              status: 'RESOLVED',
            },
          },
        },
      },
    );

    await patientlyWaitFor(() => {
      expect(getByText(/Some lifecycle environments are disabled because they are not associated/)).toBeInTheDocument();
    });
  });

  test('Displays attached content views header in multiple CVE mode', async () => {
    const { getByText } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getByText('Associated content view environments')).toBeInTheDocument();
    });
  });

  test('Does NOT display attached content views header in single CVE mode', async () => {
    const { queryByText } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews={false}
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(queryByText('Associated content view environments')).not.toBeInTheDocument();
    });
  });

  test('Cancel button closes modal', async () => {
    const closeModal = jest.fn();
    const { getAllByRole } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={closeModal}
        hostId={1}
        hostName="test-host"
        orgId={1}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      const cancelButton = getAllByRole('button', { name: 'Cancel' })[0];
      expect(cancelButton).toBeInTheDocument();
    });

    const cancelButton = getAllByRole('button', { name: 'Cancel' })[0];
    await act(async () => {
      userEvent.click(cancelButton);
    });

    expect(closeModal).toHaveBeenCalled();
  });

  test('Initializes with single existing assignment in single CVE mode', async () => {
    const existingAssignments = [
      {
        contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
        environment: { id: 1, name: 'Library', label: 'Library' },
      },
    ];

    const { getByText, queryByRole } = renderWithRedux(
      <AssignHostCVModal
        isOpen
        closeModal={jest.fn()}
        hostId={1}
        hostName="test-host"
        orgId={1}
        existingAssignments={existingAssignments}
        allowMultipleContentViews={false}
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getByText('cv_1')).toBeInTheDocument();
      // No remove button in single CVE mode
      expect(queryByRole('button', { name: 'Remove' })).not.toBeInTheDocument();
    });
  });

  describe('Change detection and Save button enablement', () => {
    test('Save button disabled when no changes made to existing assignments', async () => {
      const existingAssignments = [
        {
          contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
          environment: { id: 1, name: 'Library', label: 'Library' },
          cveLabel: 'Library/cv_1',
        },
      ];

      const { getAllByRole } = renderWithRedux(
        <AssignHostCVModal
          isOpen
          closeModal={jest.fn()}
          hostId={123}
          hostName="test-host"
          orgId={1}
          existingAssignments={existingAssignments}
          allowMultipleContentViews
        />,
        renderOptions(),
      );

      await patientlyWaitFor(() => {
        const saveButton = getAllByRole('button', { name: 'Save' })[0];
        expect(saveButton).toBeInTheDocument();
      });

      // Save button should be disabled when no changes made
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      expect(saveButton).toHaveAttribute('aria-disabled', 'true');
    });

    test('Save button enabled when assignment is removed', async () => {
      const existingAssignments = [
        {
          contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
          environment: { id: 1, name: 'Library', label: 'Library' },
          cveLabel: 'Library/cv_1',
        },
        {
          contentView: { id: 3, name: 'cv_2', label: 'cv_2' },
          environment: { id: 2, name: 'dev', label: 'dev' },
          cveLabel: 'dev/cv_2',
        },
      ];

      // Mock content views fetch for dev environment
      nockInstance
        .get(contentViewsUrl)
        .query(getCVQuery(2))
        .reply(200, mockContentViews);

      const { getAllByRole } = renderWithRedux(
        <AssignHostCVModal
          isOpen
          closeModal={jest.fn()}
          hostId={123}
          hostName="test-host"
          orgId={1}
          existingAssignments={existingAssignments}
          allowMultipleContentViews
        />,
        renderOptions(),
      );

      // Initially disabled
      await patientlyWaitFor(() => {
        const saveButton = getAllByRole('button', { name: 'Save' })[0];
        expect(saveButton).toHaveAttribute('aria-disabled', 'true');
      });

      // Remove one assignment
      const removeButtons = getAllByRole('button', { name: 'Remove' });
      await act(async () => {
        userEvent.click(removeButtons[0]);
      });

      // Save button should now be enabled
      await patientlyWaitFor(() => {
        const saveButton = getAllByRole('button', { name: 'Save' })[0];
        expect(saveButton).not.toHaveAttribute('aria-disabled', 'true');
      });
    });

    test('Save button stays disabled when incomplete assignment is added', async () => {
      const existingAssignments = [
        {
          contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
          environment: { id: 1, name: 'Library', label: 'Library' },
          cveLabel: 'Library/cv_1',
        },
      ];

      const { getAllByRole, getByRole } = renderWithRedux(
        <AssignHostCVModal
          isOpen
          closeModal={jest.fn()}
          hostId={123}
          hostName="test-host"
          orgId={1}
          existingAssignments={existingAssignments}
          allowMultipleContentViews
        />,
        renderOptions(),
      );

      // Initially disabled
      await patientlyWaitFor(() => {
        const saveButton = getAllByRole('button', { name: 'Save' })[0];
        expect(saveButton).toHaveAttribute('aria-disabled', 'true');
      });

      // Wait for the add button to be enabled (assignments loaded)
      await patientlyWaitFor(() => {
        const addButton = getByRole('button', { name: 'Assign another content view environment' });
        expect(addButton).not.toHaveAttribute('disabled');
      });

      // Add another assignment
      const addButton = getByRole('button', { name: 'Assign another content view environment' });
      await act(async () => {
        userEvent.click(addButton);
      });

      // Verify there are now 2 remove buttons (2 assignments)
      await patientlyWaitFor(() => {
        const removeButtons = getAllByRole('button', { name: 'Remove' });
        expect(removeButtons).toHaveLength(2);
      });

      // Save button stays disabled because new assignment is incomplete
      // (change detection sees length change, but canSave requires all fields filled)
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      expect(saveButton).toHaveAttribute('aria-disabled', 'true');
    });

    test('Save button remains disabled when assignments are reordered to same order', async () => {
      const existingAssignments = [
        {
          contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
          environment: { id: 1, name: 'Library', label: 'Library' },
          cveLabel: 'Library/cv_1',
        },
        {
          contentView: { id: 3, name: 'cv_2', label: 'cv_2' },
          environment: { id: 2, name: 'dev', label: 'dev' },
          cveLabel: 'dev/cv_2',
        },
      ];

      // Mock content views fetch for dev environment
      nockInstance
        .get(contentViewsUrl)
        .query(getCVQuery(2))
        .reply(200, mockContentViews);

      const { getAllByRole } = renderWithRedux(
        <AssignHostCVModal
          isOpen
          closeModal={jest.fn()}
          hostId={123}
          hostName="test-host"
          orgId={1}
          existingAssignments={existingAssignments}
          allowMultipleContentViews
        />,
        renderOptions(),
      );

      // Save button should be disabled (no changes)
      await patientlyWaitFor(() => {
        const saveButton = getAllByRole('button', { name: 'Save' })[0];
        expect(saveButton).toHaveAttribute('aria-disabled', 'true');
      });
    });

    test('Save button stays disabled when all assignments removed (length = 0)', async () => {
      const existingAssignments = [
        {
          contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
          environment: { id: 1, name: 'Library', label: 'Library' },
          cveLabel: 'Library/cv_1',
        },
      ];

      const { getAllByRole, queryByRole } = renderWithRedux(
        <AssignHostCVModal
          isOpen
          closeModal={jest.fn()}
          hostId={123}
          hostName="test-host"
          orgId={1}
          existingAssignments={existingAssignments}
          allowMultipleContentViews
        />,
        renderOptions(),
      );

      // Initially disabled - no changes
      await patientlyWaitFor(() => {
        const saveButton = getAllByRole('button', { name: 'Save' })[0];
        expect(saveButton).toHaveAttribute('aria-disabled', 'true');
      });

      // Remove the only assignment
      const removeButton = getAllByRole('button', { name: 'Remove' })[0];
      await act(async () => {
        userEvent.click(removeButton);
      });

      // Verify the assignment was removed
      await patientlyWaitFor(() => {
        expect(queryByRole('button', { name: 'Remove' })).not.toBeInTheDocument();
      });

      // Button stays disabled because canSave requires assignments.length > 0
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      expect(saveButton).toHaveAttribute('aria-disabled', 'true');
    });
  });

  describe('Save flow', () => {
    let mockAssignHostCVEnvironments;
    let mockTriggerJobStart;

    beforeEach(() => {
      // Mock getHostDetails to prevent API calls
      jest.spyOn(hostDetailsActions, 'getHostDetails').mockReturnValue({
        type: 'MOCK_GET_HOST_DETAILS',
      });

      // Mock the assignHostCVEnvironments action
      // It should call the success callback (third parameter)
      mockAssignHostCVEnvironments = jest.fn((params, hostId, handleSuccess) => {
        if (handleSuccess) {
          handleSuccess();
        }
        return { type: 'MOCK_ASSIGN' };
      });
      jest.spyOn(actions, 'assignHostCVEnvironments').mockImplementation(mockAssignHostCVEnvironments);

      // Mock the useRexJobPolling hook
      mockTriggerJobStart = jest.fn();
      jest.spyOn(rexHooks, 'useRexJobPolling').mockReturnValue({
        triggerJobStart: mockTriggerJobStart,
      });
    });

    afterEach(() => {
      jest.restoreAllMocks();
    });

    test('Save with existing assignment preserves cveLabel', async () => {
      const existingAssignments = [
        {
          contentView: {
            id: 2,
            name: 'cv_1',
            label: 'cv_1',
            content_view_default: false,
            default: false,
          },
          environment: {
            id: 1,
            name: 'Library',
            label: 'Library',
            library: true,
          },
          cveLabel: 'Library/cv_1', // Existing label from API
        },
        {
          contentView: {
            id: 1,
            name: 'Default Organization View',
            label: 'Default_Organization_View',
            content_view_default: true,
            default: true,
          },
          environment: {
            id: 1,
            name: 'Library',
            label: 'Library',
            library: true,
          },
          cveLabel: 'Library', // Default CV in Library uses just env label
        },
      ];

      const { getAllByRole } = renderWithRedux(
        <AssignHostCVModal
          isOpen
          closeModal={jest.fn()}
          hostId={123}
          hostName="test-host"
          orgId={1}
          existingAssignments={existingAssignments}
          allowMultipleContentViews
        />,
        renderOptions(),
      );

      await patientlyWaitFor(() => {
        const saveButton = getAllByRole('button', { name: 'Save' })[0];
        expect(saveButton).toBeInTheDocument();
      });

      // Remove one assignment to trigger a change
      const removeButtons = getAllByRole('button', { name: 'Remove' });
      await act(async () => {
        userEvent.click(removeButtons[1]); // Remove second assignment
      });

      // Wait for Save button to be enabled
      await patientlyWaitFor(() => {
        const saveButton = getAllByRole('button', { name: 'Save' })[0];
        expect(saveButton).not.toHaveAttribute('aria-disabled', 'true');
      });

      // Click Save
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      await act(async () => {
        userEvent.click(saveButton);
      });

      // Verify API was called with existing cveLabel preserved for first assignment
      await patientlyWaitFor(() => {
        expect(mockAssignHostCVEnvironments).toHaveBeenCalledWith(
          expect.objectContaining({
            id: 123,
            host: {
              content_facet_attributes: {
                content_view_environments: ['Library/cv_1'],
              },
            },
          }),
          123,
          expect.any(Function),
          expect.any(Function),
        );
      });
    });

    test('Save with new assignment builds label from env/CV labels (non-default CV)', async () => {
      const { getAllByRole, getByRole } = renderWithRedux(
        <AssignHostCVModal
          isOpen
          closeModal={jest.fn()}
          hostId={123}
          hostName="test-host"
          orgId={1}
          allowMultipleContentViews
        />,
        renderOptions(),
      );

      // Wait for Library to be pre-selected
      await patientlyWaitFor(() => {
        expect(getAllByRole('radio', { name: firstEnv.name })[0]).toBeChecked();
      });

      // Click to open CV select
      const cvSelectButton = getByRole('button', { name: 'Options menu' });
      await act(async () => {
        userEvent.click(cvSelectButton);
      });

      // Select a non-default CV (cv_1)
      await patientlyWaitFor(() => {
        expect(getByRole('option', { name: /cv_1/ })).toBeInTheDocument();
      });

      const cvOption = getByRole('option', { name: /cv_1/ });
      await act(async () => {
        userEvent.click(cvOption);
      });

      // Wait for Save button to be enabled
      await patientlyWaitFor(() => {
        const saveButton = getAllByRole('button', { name: 'Save' })[0];
        expect(saveButton).not.toHaveAttribute('aria-disabled', 'true');
      });

      // Click Save
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      await act(async () => {
        userEvent.click(saveButton);
      });

      // Verify API was called with constructed label (Library/cv_1)
      await patientlyWaitFor(() => {
        expect(mockAssignHostCVEnvironments).toHaveBeenCalledWith(
          expect.objectContaining({
            id: 123,
            host: {
              content_facet_attributes: {
                content_view_environments: ['Library/cv_1'],
              },
            },
          }),
          123,
          expect.any(Function),
          expect.any(Function),
        );
      });
    });

    test('Save with Library + default CV uses just "Library" label', async () => {
      const { getAllByRole, getByRole } = renderWithRedux(
        <AssignHostCVModal
          isOpen
          closeModal={jest.fn()}
          hostId={123}
          hostName="test-host"
          orgId={1}
          allowMultipleContentViews
        />,
        renderOptions(),
      );

      // Wait for Library to be pre-selected
      await patientlyWaitFor(() => {
        expect(getAllByRole('radio', { name: firstEnv.name })[0]).toBeChecked();
      });

      // Click to open CV select
      const cvSelectButton = getByRole('button', { name: 'Options menu' });
      await act(async () => {
        userEvent.click(cvSelectButton);
      });

      // Select Default Organization View
      await patientlyWaitFor(() => {
        expect(getByRole('option', { name: /Default Organization View/ })).toBeInTheDocument();
      });

      const cvOption = getByRole('option', { name: /Default Organization View/ });
      await act(async () => {
        userEvent.click(cvOption);
      });

      // Wait for Save button to be enabled
      await patientlyWaitFor(() => {
        const saveButton = getAllByRole('button', { name: 'Save' })[0];
        expect(saveButton).not.toHaveAttribute('aria-disabled', 'true');
      });

      // Click Save
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      await act(async () => {
        userEvent.click(saveButton);
      });

      // Verify API was called with just "Library" label
      await patientlyWaitFor(() => {
        expect(mockAssignHostCVEnvironments).toHaveBeenCalledWith(
          expect.objectContaining({
            id: 123,
            host: {
              content_facet_attributes: {
                content_view_environments: ['Library'],
              },
            },
          }),
          123,
          expect.any(Function),
          expect.any(Function),
        );
      });
    });

    test('Save with multiple assignments preserves order', async () => {
      const existingAssignments = [
        {
          contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
          environment: { id: 1, name: 'Library', label: 'Library' },
          cveLabel: 'Library/cv_1',
        },
        {
          contentView: { id: 3, name: 'composite_cv', label: 'composite_cv' },
          environment: { id: 2, name: 'dev', label: 'dev' },
          cveLabel: 'dev/composite_cv',
        },
        {
          contentView: { id: 4, name: 'cv_2', label: 'cv_2' },
          environment: { id: 3, name: 'prod', label: 'prod' },
          cveLabel: 'prod/cv_2',
        },
      ];

      // Mock content views fetch for environments
      nockInstance
        .get(contentViewsUrl)
        .query(getCVQuery(2))
        .reply(200, mockContentViews);
      nockInstance
        .get(contentViewsUrl)
        .query(getCVQuery(3))
        .reply(200, mockContentViews);

      const { getAllByRole } = renderWithRedux(
        <AssignHostCVModal
          isOpen
          closeModal={jest.fn()}
          hostId={123}
          hostName="test-host"
          orgId={1}
          existingAssignments={existingAssignments}
          allowMultipleContentViews
        />,
        renderOptions(),
      );

      await patientlyWaitFor(() => {
        const saveButton = getAllByRole('button', { name: 'Save' })[0];
        expect(saveButton).toBeInTheDocument();
      });

      // Remove the middle assignment to trigger a change
      const removeButtons = getAllByRole('button', { name: 'Remove' });
      await act(async () => {
        userEvent.click(removeButtons[1]); // Remove second assignment
      });

      // Wait for Save button to be enabled
      await patientlyWaitFor(() => {
        const saveButton = getAllByRole('button', { name: 'Save' })[0];
        expect(saveButton).not.toHaveAttribute('aria-disabled', 'true');
      });

      // Click Save
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      await act(async () => {
        userEvent.click(saveButton);
      });

      // Verify API was called with labels in correct order (first and third)
      await patientlyWaitFor(() => {
        expect(mockAssignHostCVEnvironments).toHaveBeenCalledWith(
          expect.objectContaining({
            id: 123,
            host: {
              content_facet_attributes: {
                content_view_environments: ['Library/cv_1', 'prod/cv_2'],
              },
            },
          }),
          123,
          expect.any(Function),
          expect.any(Function),
        );
      });
    });

    test('Changing CV in existing assignment builds new label instead of reusing old cveLabel', async () => {
      const existingAssignments = [
        {
          contentView: {
            id: 2,
            name: 'cv_1',
            label: 'cv_1',
            content_view_default: false,
            default: false,
          },
          environment: {
            id: 1,
            name: 'Library',
            label: 'Library',
            library: true,
          },
          cveLabel: 'Library/cv_1', // User currently has cv_1
        },
      ];

      const { getByRole } = renderWithRedux(
        <AssignHostCVModal
          isOpen
          closeModal={jest.fn()}
          hostId={123}
          hostName="test-host"
          orgId={1}
          existingAssignments={existingAssignments}
          allowMultipleContentViews={false}
        />,
        renderOptions(),
      );

      // Wait for assignment to load
      await patientlyWaitFor(() => {
        expect(getByRole('button', { name: 'Save' })).toBeInTheDocument();
      });

      // Wait a moment for the assignment section to initialize
      await patientlyWaitFor(() => {
        // The environment name should be visible as a link in the toggle content
        expect(getByRole('link', { name: 'Library' })).toBeInTheDocument();
      });

      // Now wait for the CV select to be available (should be auto-expanded for single assignment)
      await patientlyWaitFor(() => {
        expect(getByRole('button', { name: 'Options menu' })).toBeInTheDocument();
      });

      const cvSelectButton = getByRole('button', { name: 'Options menu' });
      await act(async () => {
        userEvent.click(cvSelectButton);
      });

      // Select a DIFFERENT CV (cv_2 instead of cv_1) in the same environment (Library)
      await patientlyWaitFor(() => {
        expect(getByRole('option', { name: /composite_cv/ })).toBeInTheDocument();
      });

      const cvOption = getByRole('option', { name: /composite_cv/ });
      await act(async () => {
        userEvent.click(cvOption);
      });

      // Wait for Save button to be enabled (change detected)
      await patientlyWaitFor(() => {
        const saveButton = getByRole('button', { name: 'Save' });
        expect(saveButton).not.toHaveAttribute('aria-disabled', 'true');
      });

      // Click Save
      const saveButton = getByRole('button', { name: 'Save' });
      await act(async () => {
        userEvent.click(saveButton);
      });

      // Verify API was called with NEW label (Library/composite_cv),
      // NOT the old cveLabel (Library/cv_1)
      await patientlyWaitFor(() => {
        expect(mockAssignHostCVEnvironments).toHaveBeenCalledWith(
          expect.objectContaining({
            id: 123,
            host: {
              content_facet_attributes: {
                content_view_environments: ['Library/composite_cv'],
              },
            },
          }),
          123,
          expect.any(Function),
          expect.any(Function),
        );
      });
    });

    test('Save in single CVE mode sends single label', async () => {
      const { getAllByRole, getByRole } = renderWithRedux(
        <AssignHostCVModal
          isOpen
          closeModal={jest.fn()}
          hostId={123}
          hostName="test-host"
          orgId={1}
          allowMultipleContentViews={false}
        />,
        renderOptions(),
      );

      // Wait for Library to be pre-selected
      await patientlyWaitFor(() => {
        expect(getAllByRole('radio', { name: firstEnv.name })[0]).toBeChecked();
      });

      // Click to open CV select
      const cvSelectButton = getByRole('button', { name: 'Options menu' });
      await act(async () => {
        userEvent.click(cvSelectButton);
      });

      // Select a CV
      await patientlyWaitFor(() => {
        expect(getByRole('option', { name: /cv_1/ })).toBeInTheDocument();
      });

      const cvOption = getByRole('option', { name: /cv_1/ });
      await act(async () => {
        userEvent.click(cvOption);
      });

      // Wait for Save button to be enabled
      await patientlyWaitFor(() => {
        const saveButton = getAllByRole('button', { name: 'Save' })[0];
        expect(saveButton).not.toHaveAttribute('aria-disabled', 'true');
      });

      // Click Save
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      await act(async () => {
        userEvent.click(saveButton);
      });

      // Verify API was called with single label in array
      await patientlyWaitFor(() => {
        expect(mockAssignHostCVEnvironments).toHaveBeenCalledWith(
          expect.objectContaining({
            id: 123,
            host: {
              content_facet_attributes: {
                content_view_environments: ['Library/cv_1'],
              },
            },
          }),
          123,
          expect.any(Function),
          expect.any(Function),
        );
      });
    });

    test('Save with forceProfileUpload triggers remote execution', async () => {
      const { getAllByRole, getByRole } = renderWithRedux(
        <AssignHostCVModal
          isOpen
          closeModal={jest.fn()}
          hostId={123}
          hostName="test-host"
          orgId={1}
          allowMultipleContentViews
        />,
        renderOptions(),
      );

      // Wait for Library to be pre-selected
      await patientlyWaitFor(() => {
        expect(getAllByRole('radio', { name: firstEnv.name })[0]).toBeChecked();
      });

      // Select a CV
      const cvSelectButton = getByRole('button', { name: 'Options menu' });
      await act(async () => {
        userEvent.click(cvSelectButton);
      });

      await patientlyWaitFor(() => {
        expect(getByRole('option', { name: /cv_1/ })).toBeInTheDocument();
      });

      const cvOption = getByRole('option', { name: /cv_1/ });
      await act(async () => {
        userEvent.click(cvOption);
      });

      // Check the force profile upload checkbox
      const checkbox = getByRole('checkbox', { name: 'Update the host immediately via remote execution' });
      await act(async () => {
        userEvent.click(checkbox);
      });

      // Wait for Save button to be enabled
      await patientlyWaitFor(() => {
        const saveButton = getAllByRole('button', { name: 'Save' })[0];
        expect(saveButton).not.toHaveAttribute('aria-disabled', 'true');
      });

      // Click Save
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      await act(async () => {
        userEvent.click(saveButton);
      });

      // Verify remote execution was triggered
      await patientlyWaitFor(() => {
        expect(mockTriggerJobStart).toHaveBeenCalledWith('test-host');
      });
    });

    test('Save without forceProfileUpload does not trigger remote execution', async () => {
      const { getAllByRole, getByRole } = renderWithRedux(
        <AssignHostCVModal
          isOpen
          closeModal={jest.fn()}
          hostId={123}
          hostName="test-host"
          orgId={1}
          allowMultipleContentViews
        />,
        renderOptions(),
      );

      // Wait for Library to be pre-selected
      await patientlyWaitFor(() => {
        expect(getAllByRole('radio', { name: firstEnv.name })[0]).toBeChecked();
      });

      // Select a CV
      const cvSelectButton = getByRole('button', { name: 'Options menu' });
      await act(async () => {
        userEvent.click(cvSelectButton);
      });

      await patientlyWaitFor(() => {
        expect(getByRole('option', { name: /cv_1/ })).toBeInTheDocument();
      });

      const cvOption = getByRole('option', { name: /cv_1/ });
      await act(async () => {
        userEvent.click(cvOption);
      });

      // Wait for Save button to be enabled
      await patientlyWaitFor(() => {
        const saveButton = getAllByRole('button', { name: 'Save' })[0];
        expect(saveButton).not.toHaveAttribute('aria-disabled', 'true');
      });

      // Click Save without checking forceProfileUpload
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      await act(async () => {
        userEvent.click(saveButton);
      });

      // Verify remote execution was NOT triggered
      expect(mockTriggerJobStart).not.toHaveBeenCalled();
    });
  });
});
