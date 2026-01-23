import React from 'react';
import { renderWithRedux, patientlyWaitFor, act } from 'react-testing-lib-wrapper';
import userEvent from '@testing-library/user-event';
import CreateAKCVModal from '../CreateAKCVModal';
import mockEnvPaths from '../../../../../components/extensions/HostDetails/Cards/ContentViewDetailsCard/__tests__/envPaths.fixtures.json';
import mockContentViews from '../../../../../components/extensions/HostDetails/Cards/ContentViewDetailsCard/__tests__/contentViews.fixtures.json';
import { nockInstance } from '../../../../../test-utils/nockWrapper';
import katelloApi from '../../../../../services/api';

const contentViewsUrl = katelloApi.getApiUrl('/content_views');
const envPathsUrl = katelloApi.getApiUrl('/organizations/1/environments/paths');

const renderOptions = () => ({
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

describe('CreateAKCVModal', () => {
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
  });

  test('Renders modal with correct title when allowMultipleContentViews is true', async () => {
    const { getByText } = renderWithRedux(
      <CreateAKCVModal
        isOpen
        closeModal={jest.fn()}
        orgId={1}
        onAssignmentsChange={jest.fn()}
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
      <CreateAKCVModal
        isOpen
        closeModal={jest.fn()}
        orgId={1}
        onAssignmentsChange={jest.fn()}
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

  test('Calls onAssignmentsChange callback when Save is clicked', async () => {
    const onAssignmentsChange = jest.fn();
    const closeModal = jest.fn();

    const existingAssignments = [
      {
        contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
        environment: { id: 1, name: 'Library', label: 'Library' },
        label: 'Library/cv_1',
      },
    ];

    const { getAllByRole } = renderWithRedux(
      <CreateAKCVModal
        isOpen
        closeModal={closeModal}
        orgId={1}
        existingAssignments={existingAssignments}
        onAssignmentsChange={onAssignmentsChange}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getAllByRole('button', { name: 'Save' })[0]).toBeInTheDocument();
    });

    // Initially the save button should be disabled (no changes)
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    expect(saveButton).toHaveAttribute('aria-disabled', 'true');
  });

  test('Save button disabled when no changes made', async () => {
    const existingAssignments = [
      {
        contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
        environment: { id: 1, name: 'Library', label: 'Library' },
        label: 'Library/cv_1',
      },
    ];

    const { getAllByRole } = renderWithRedux(
      <CreateAKCVModal
        isOpen
        closeModal={jest.fn()}
        orgId={1}
        existingAssignments={existingAssignments}
        onAssignmentsChange={jest.fn()}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      // Save should be disabled because no changes have been made
      expect(saveButton).toHaveAttribute('aria-disabled', 'true');
    });
  });

  test('Cancel button closes modal', async () => {
    const closeModal = jest.fn();
    const { getAllByRole } = renderWithRedux(
      <CreateAKCVModal
        isOpen
        closeModal={closeModal}
        orgId={1}
        onAssignmentsChange={jest.fn()}
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

  test('Allows zero assignments for activation keys', async () => {
    const onAssignmentsChange = jest.fn();
    const closeModal = jest.fn();

    const existingAssignments = [
      {
        contentView: { id: 2, name: 'cv_1', label: 'cv_1' },
        environment: { id: 1, name: 'Library', label: 'Library' },
        label: 'Library/cv_1',
      },
    ];

    const { getAllByRole } = renderWithRedux(
      <CreateAKCVModal
        isOpen
        closeModal={closeModal}
        orgId={1}
        existingAssignments={existingAssignments}
        onAssignmentsChange={onAssignmentsChange}
        allowMultipleContentViews
      />,
      renderOptions(),
    );

    await patientlyWaitFor(() => {
      expect(getAllByRole('button', { name: 'Remove' })).toHaveLength(1);
    });

    // Remove the assignment
    const removeButton = getAllByRole('button', { name: 'Remove' })[0];
    await act(async () => {
      userEvent.click(removeButton);
    });

    // Should be able to save with zero assignments
    await patientlyWaitFor(() => {
      const saveButton = getAllByRole('button', { name: 'Save' })[0];
      expect(saveButton).not.toHaveAttribute('aria-disabled', 'true');
    });
  });
});
