import React from 'react';
import { renderWithRedux, patientlyWaitFor, act } from 'react-testing-lib-wrapper';
import userEvent from '@testing-library/user-event';
import AssignAKCVModal from '../AssignAKCVModal';
import mockEnvPaths from '../../../../../components/extensions/HostDetails/Cards/ContentViewDetailsCard/__tests__/envPaths.fixtures.json';
import mockContentViews from '../../../../../components/extensions/HostDetails/Cards/ContentViewDetailsCard/__tests__/contentViews.fixtures.json';
import AK_CV_AND_ENV_KEY from '../AKContentViewConstants';
import { assertNockRequest, nockInstance } from '../../../../../test-utils/nockWrapper';
import katelloApi from '../../../../../services/api';

const contentViewsUrl = katelloApi.getApiUrl('/content_views');
const envPathsUrl = katelloApi.getApiUrl('/organizations/1/environments/paths');

const renderOptions = () => ({
  apiNamespace: AK_CV_AND_ENV_KEY,
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

describe('AssignAKCVModal', () => {
  let originalFetch;
  let originalGetElementById;
  let originalAngular;

  beforeEach(() => {
    // Mock the environment paths API call
    nockInstance
      .get(envPathsUrl)
      .query(true)
      .reply(200, mockEnvPaths);

    // Mock the content views fetch
    nockInstance
      .get(contentViewsUrl)
      .query(getCVQuery(firstEnv.id))
      .reply(200, mockContentViews)
      .persist();

    // Save originals
    originalFetch = global.fetch;
    originalGetElementById = document.getElementById;
    originalAngular = global.window.angular;
  });

  afterEach(() => {
    // Restore originals
    if (originalFetch !== undefined) global.fetch = originalFetch;
    if (originalGetElementById !== undefined) document.getElementById = originalGetElementById;
    if (originalAngular !== undefined) {
      global.window.angular = originalAngular;
    } else {
      delete global.window.angular;
    }
  });

  test('Renders modal with correct title and description when allowMultipleContentViews is true', async () => {
    const { getByText } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={jest.fn()}
        akId={1}
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

  test('Renders modal without multiple assignment text when allowMultipleContentViews is false', async () => {
    const { getByText, queryByText } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={jest.fn()}
        akId={1}
        orgId={1}
        allowMultipleContentViews={false}
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getByText('Assign content view environments')).toBeInTheDocument();
      expect(getByText(/A content view environment is a combination of a particular lifecycle environment and content view\./)).toBeInTheDocument();
      expect(queryByText(/You can assign multiple content view environments/)).not.toBeInTheDocument();
    });
  });

  test('Starts with one empty assignment when no existing assignments', async () => {
    const { getByText } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={jest.fn()}
        akId={1}
        orgId={1}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getByText('Select a content view')).toBeInTheDocument();
    });
  });

  test('Add another content view button exists when allowMultipleContentViews is true', async () => {
    const { getByText } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={jest.fn()}
        akId={1}
        orgId={1}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getByText('Assign another content view environment')).toBeInTheDocument();
    });
  });

  test('Add another content view button is disabled when allowMultipleContentViews is false', async () => {
    const { getByText } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={jest.fn()}
        akId={1}
        orgId={1}
        allowMultipleContentViews={false}
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      const addButton = getByText('Assign another content view environment').closest('button');
      expect(addButton).toHaveAttribute('aria-disabled', 'true');
    });
  });

  test('Displays remove button when allowMultipleContentViews is true', async () => {
    const { getAllByRole } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={jest.fn()}
        akId={1}
        orgId={1}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getAllByRole('button', { name: 'Remove' })).toHaveLength(1);
    });
  });

  test('Displays remove button even with single assignment (activation keys allow zero assignments)', async () => {
    const { getAllByRole } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={jest.fn()}
        akId={1}
        orgId={1}
        allowMultipleContentViews={false}
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      // Should show remove button even with single assignment since AKs can have zero
      expect(getAllByRole('button', { name: 'Remove' })).toHaveLength(1);
    });
  });

  test('Displays remove buttons with multiple assignments even when allowMultipleContentViews is false', async () => {
    const existingAssignments = [
      {
        contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
        environment: { id: 1, name: 'Library', label: 'Library' },
        label: 'Library/cv_1',
      },
      {
        contentView: { id: 3, name: 'composite_cv', label: 'composite_cv' },
        environment: { id: 2, name: 'dev', label: 'dev' },
        label: 'dev/composite_cv',
      },
    ];

    // Mock content views fetch for environment id 2 (dev)
    nockInstance
      .get(contentViewsUrl)
      .query(getCVQuery(2))
      .reply(200, mockContentViews);

    const { getAllByRole } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={jest.fn()}
        akId={1}
        orgId={1}
        existingAssignments={existingAssignments}
        allowMultipleContentViews={false}
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      // Should show remove buttons so user can reduce to 1 assignment
      expect(getAllByRole('button', { name: 'Remove' })).toHaveLength(2);
    });
  });

  test('Save button disabled with multiple assignments when allowMultipleContentViews is false', async () => {
    const existingAssignments = [
      {
        contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
        environment: { id: 1, name: 'Library', label: 'Library' },
        label: 'Library/cv_1',
      },
      {
        contentView: { id: 3, name: 'composite_cv', label: 'composite_cv' },
        environment: { id: 2, name: 'dev', label: 'dev' },
        label: 'dev/composite_cv',
      },
    ];

    // Mock content views fetch for environment id 2 (dev)
    nockInstance
      .get(contentViewsUrl)
      .query(getCVQuery(2))
      .reply(200, mockContentViews);

    const { getAllByRole } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={jest.fn()}
        akId={1}
        orgId={1}
        existingAssignments={existingAssignments}
        allowMultipleContentViews={false}
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      // Save should be disabled because there are 2 assignments
      expect(saveButton).toHaveAttribute('aria-disabled', 'true');
    });
  });

  test('Save button enabled after removing one assignment when allowMultipleContentViews is false', async () => {
    const existingAssignments = [
      {
        contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
        environment: { id: 1, name: 'Library', label: 'Library' },
        label: 'Library/cv_1',
      },
      {
        contentView: { id: 3, name: 'composite_cv', label: 'composite_cv' },
        environment: { id: 2, name: 'dev', label: 'dev' },
        label: 'dev/composite_cv',
      },
    ];

    // Mock content views fetch for environment id 2 (dev)
    nockInstance
      .get(contentViewsUrl)
      .query(getCVQuery(2))
      .reply(200, mockContentViews);

    const { getAllByRole, queryByText } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={jest.fn()}
        akId={1}
        orgId={1}
        existingAssignments={existingAssignments}
        allowMultipleContentViews={false}
      />,
      renderOptions(),
    );

    // Initially disabled due to 2 assignments
    await patientlyWaitFor(() => {
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      expect(saveButton).toHaveAttribute('aria-disabled', 'true');
    });

    // Remove one assignment
    const removeButtons = getAllByRole('button', { name: 'Remove' });
    await act(async () => {
      userEvent.click(removeButtons[0]);
    });

    // Now should be enabled with only 1 assignment
    await patientlyWaitFor(() => {
      expect(queryByText('cv_1')).not.toBeInTheDocument();
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      expect(saveButton).not.toHaveAttribute('aria-disabled', 'true');
    });
  });

  test('Initializes with multiple existing assignments when allowMultipleContentViews is true', async () => {
    const existingAssignments = [
      {
        contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
        environment: { id: 1, name: 'Library', label: 'Library' },
        label: 'Library/cv_1',
      },
      {
        contentView: { id: 3, name: 'composite_cv', label: 'composite_cv' },
        environment: { id: 2, name: 'dev', label: 'dev' },
        label: 'dev/composite_cv',
      },
    ];

    // Mock content views fetch for environment id 2 (dev)
    nockInstance
      .get(contentViewsUrl)
      .query(getCVQuery(2))
      .reply(200, mockContentViews);

    const { getByText, getAllByRole } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={jest.fn()}
        akId={1}
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

  test('Can remove an assignment when allowMultipleContentViews is true', async () => {
    const existingAssignments = [
      {
        contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
        environment: { id: 1, name: 'Library', label: 'Library' },
        label: 'Library/cv_1',
      },
      {
        contentView: { id: 3, name: 'composite_cv', label: 'composite_cv' },
        environment: { id: 2, name: 'dev', label: 'dev' },
        label: 'dev/composite_cv',
      },
    ];

    // Mock content views fetch for environment id 2 (dev)
    nockInstance
      .get(contentViewsUrl)
      .query(getCVQuery(2))
      .reply(200, mockContentViews);

    const { getAllByRole, queryByText } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={jest.fn()}
        akId={1}
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

  test('Select environment triggers CV API call', async () => {
    const contentViewsScope = nockInstance
      .get(contentViewsUrl)
      .query(getCVQuery(firstEnv.id))
      .reply(200, mockContentViews);

    const { getAllByRole } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={jest.fn()}
        akId={1}
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

    // Verify the CV API was called
    await patientlyWaitFor(() => {
      assertNockRequest(contentViewsScope);
    });
  });

  test('Save button disabled when no CV selected', async () => {
    const { getAllByRole } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={jest.fn()}
        akId={1}
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

  test('Cancel button closes modal', async () => {
    const closeModal = jest.fn();
    const { getAllByRole } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={closeModal}
        akId={1}
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

  test('Saves with correct label payload structure', async () => {
    const existingAssignments = [
      {
        contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
        environment: { id: 1, name: 'Library', label: 'Library' },
        label: 'Library/cv_1',
      },
      {
        contentView: { id: 3, name: 'composite_cv', label: 'composite_cv' },
        environment: { id: 2, name: 'dev', label: 'dev' },
        label: 'dev/composite_cv',
      },
    ];

    // Mock content views fetch for environment id 2 (dev)
    nockInstance
      .get(contentViewsUrl)
      .query(getCVQuery(2))
      .reply(200, mockContentViews);

    let capturedRequest;
    // Mock PUT endpoint with callback to capture request body
    const putScope = nockInstance
      .put('/katello/api/v2/activation_keys/1')
      .reply(200, (uri, requestBody) => {
        capturedRequest = requestBody;
        return { id: 1, name: 'Test AK' };
      });

    // Mock DOM and Angular for refresh
    const mockElement = { setAttribute: jest.fn() };
    document.getElementById = jest.fn(() => mockElement);

    // Mock ActivationKey resource instance with $promise
    const mockActivationKeyResource = {
      $promise: Promise.resolve({ id: 1, name: 'Test AK' }),
    };

    // Mock Angular's ActivationKey service
    const mockActivationKeyService = {
      get: jest.fn(() => mockActivationKeyResource),
    };

    const mockScope = {
      $apply: jest.fn((fn) => {
        fn(); // Execute the function passed to $apply
      }),
      activationKey: null,
    };

    const mockInjector = {
      get: jest.fn((serviceName) => {
        if (serviceName === 'ActivationKey') return mockActivationKeyService;
        return null;
      }),
    };

    global.window.angular = {
      element: jest.fn(() => ({
        injector: () => mockInjector,
        scope: () => mockScope,
      })),
    };

    const { getAllByRole } = renderWithRedux(
      <AssignAKCVModal
        isOpen
        closeModal={jest.fn()}
        akId={1}
        orgId={1}
        existingAssignments={existingAssignments}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    // Wait for initialization
    await patientlyWaitFor(() => {
      expect(getAllByRole('button', { name: 'Remove' })).toHaveLength(2);
    });

    // Remove one assignment
    const removeButtons = getAllByRole('button', { name: 'Remove' });
    await act(async () => {
      userEvent.click(removeButtons[0]);
    });

    // Save should now be enabled - click it
    await patientlyWaitFor(() => {
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      expect(saveButton).not.toHaveAttribute('aria-disabled', 'true');
    });

    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    await act(async () => {
      userEvent.click(saveButton);
    });

    // Assert PUT was called with correct structure
    await assertNockRequest(putScope);
    expect(capturedRequest).toHaveProperty('id', 1);
    expect(capturedRequest).toHaveProperty('content_view_environments');
    expect(Array.isArray(capturedRequest.content_view_environments)).toBe(true);
    expect(capturedRequest.content_view_environments).toHaveLength(1);
    // Should contain the remaining assignment label
    expect(capturedRequest.content_view_environments).toContain('dev/composite_cv');
  });
});
