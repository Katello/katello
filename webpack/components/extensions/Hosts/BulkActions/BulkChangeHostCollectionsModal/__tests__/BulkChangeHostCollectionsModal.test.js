import React from 'react';
import { renderWithRedux, patientlyWaitFor, act } from 'react-testing-lib-wrapper';
import userEvent from '@testing-library/user-event';
import { addToast } from 'foremanReact/components/ToastsList';
import { nockInstance, assertNockRequest } from '../../../../../../test-utils/nockWrapper';
import katelloApi from '../../../../../../services/api';
import BulkChangeHostCollectionsModal from '../BulkChangeHostCollectionsModal';

jest.mock('foremanReact/components/ToastsList', () => ({
  addToast: jest.fn(() => ({ type: 'ADD_TOAST' })),
}));

jest.mock('foremanReact/Root/Context/ForemanContext', () => ({
  useForemanOrganization: () => ({ id: 1, name: 'Test Org' }),
}));

const hostCollectionsApiUrl = katelloApi.getApiUrl('/host_collections');
const autocompleteUrl = katelloApi.getApiUrl('/host_collections/auto_complete_search');

const mockHostCollections = {
  total: 3,
  subtotal: 3,
  page: 1,
  per_page: 5,
  results: [
    {
      id: 1,
      name: 'Test Host Collection 1',
      description: 'First test collection',
      max_hosts: 10,
      unlimited_hosts: false,
      total_hosts: 5,
    },
    {
      id: 2,
      name: 'Test Host Collection 2',
      description: 'Second test collection',
      max_hosts: null,
      unlimited_hosts: true,
      total_hosts: 3,
    },
    {
      id: 3,
      name: 'Test Host Collection 3',
      description: '',
      max_hosts: 20,
      unlimited_hosts: false,
      total_hosts: 0,
    },
  ],
};

const renderOptions = (state = {}) => ({
  apiNamespace: 'BULK_HOST_COLLECTIONS',
  initialState: {
    API: {
      ...state,
    },
  },
});

const defaultProps = {
  isOpen: true,
  closeModal: jest.fn(),
  fetchBulkParams: jest.fn(() => 'name ~ test'),
  selectedCount: 5,
};

beforeEach(() => {
  jest.clearAllMocks();
});

test('renders modal when open', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const hostCollectionsScope = nockInstance
    .get(hostCollectionsApiUrl)
    .query(true)
    .reply(200, mockHostCollections)
    .persist();

  const { getByText } = renderWithRedux(
    <BulkChangeHostCollectionsModal {...defaultProps} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    expect(getByText('Change host collections')).toBeInTheDocument();
    expect(getByText('Add to host collections')).toBeInTheDocument();
    expect(getByText('Remove from host collections')).toBeInTheDocument();
  });

  assertNockRequest(hostCollectionsScope, false);
  assertNockRequest(autocompleteScope, false);
});

test('displays host collections table', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const hostCollectionsScope = nockInstance
    .get(hostCollectionsApiUrl)
    .query(true)
    .reply(200, mockHostCollections)
    .persist();

  const { getByText } = renderWithRedux(
    <BulkChangeHostCollectionsModal {...defaultProps} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    expect(getByText('Test Host Collection 1')).toBeInTheDocument();
    expect(getByText('Test Host Collection 2')).toBeInTheDocument();
    expect(getByText('Test Host Collection 3')).toBeInTheDocument();
    expect(getByText('First test collection')).toBeInTheDocument();
    expect(getByText('Second test collection')).toBeInTheDocument();
    expect(getByText('5/10')).toBeInTheDocument(); // limit display
    expect(getByText('3/unlimited')).toBeInTheDocument(); // unlimited hosts
  });

  assertNockRequest(hostCollectionsScope, false);
  assertNockRequest(autocompleteScope, false);
});

test('Save button is disabled when no host collections selected', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const hostCollectionsScope = nockInstance
    .get(hostCollectionsApiUrl)
    .query(true)
    .reply(200, mockHostCollections)
    .persist();

  const { getAllByRole } = renderWithRedux(
    <BulkChangeHostCollectionsModal {...defaultProps} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    expect(saveButton).toBeInTheDocument();
    expect(saveButton).toHaveAttribute('aria-disabled', 'true');
  });

  assertNockRequest(hostCollectionsScope, false);
  assertNockRequest(autocompleteScope, false);
});

test('Save button is enabled when host collection is selected', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const hostCollectionsScope = nockInstance
    .get(hostCollectionsApiUrl)
    .query(true)
    .reply(200, mockHostCollections)
    .persist();

  const { getAllByRole, getByText } = renderWithRedux(
    <BulkChangeHostCollectionsModal {...defaultProps} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    expect(getByText('Test Host Collection 1')).toBeInTheDocument();
  });

  let checkboxes;
  await act(async () => {
    checkboxes = getAllByRole('checkbox');
    // Click first host collection checkbox (skip the select all checkbox)
    await userEvent.click(checkboxes[1]);
  });

  await patientlyWaitFor(() => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    expect(saveButton).toHaveAttribute('aria-disabled', 'false');
  });

  assertNockRequest(hostCollectionsScope, false);
  assertNockRequest(autocompleteScope, false);
});

// Test loading state of Save button
test('Save button is disabled and shows loading indicator while fetching host collections', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const hostCollectionsScope = nockInstance
    .get(hostCollectionsApiUrl)
    .query(true)
    .reply(200, mockHostCollections)
    .persist();

  const { getAllByRole } = renderWithRedux(
    <BulkChangeHostCollectionsModal {...defaultProps} />,
    renderOptions(),
  );

  // Immediately after render, before host collections resolve
  const saveButton = getAllByRole('button', { name: /Save/ })[0];
  expect(saveButton).toBeInTheDocument();
  expect(saveButton).toHaveAttribute('aria-disabled', 'true');

  // Check for loading indicator (adjust selector as needed for your implementation)
  // Example: spinner, loading text, etc.
  // If your Save button shows a spinner or "Loading..." text, check for it:
  // expect(getByText(/loading/i)).toBeInTheDocument();
  // Or if you use a spinner with a test id:
  // expect(saveButton.querySelector('[data-testid="loading-spinner"]')).toBeInTheDocument();

  // Wait for host collections to load
  await patientlyWaitFor(() => {
    expect(saveButton).toBeInTheDocument();
    // After loading, Save button should still be disabled if no selection
    expect(saveButton).toHaveAttribute('aria-disabled', 'true');
  });

  assertNockRequest(hostCollectionsScope, false);
  assertNockRequest(autocompleteScope, false);
});

test('switches between Add and Remove radio buttons', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const hostCollectionsScope = nockInstance
    .get(hostCollectionsApiUrl)
    .query(true)
    .reply(200, mockHostCollections)
    .persist();

  const { getByLabelText, getByText } = renderWithRedux(
    <BulkChangeHostCollectionsModal {...defaultProps} />,
    renderOptions(),
  );

  // Wait for host collections to load so Remove radio is enabled
  await patientlyWaitFor(() => {
    expect(getByText('Test Host Collection 1')).toBeInTheDocument();
    const addRadio = getByLabelText('Add to host collections');
    const removeRadio = getByLabelText('Remove from host collections');

    expect(addRadio).toBeChecked();
    expect(removeRadio).not.toBeChecked();
    expect(removeRadio).not.toBeDisabled();
  });

  await act(async () => {
    const removeRadio = getByLabelText('Remove from host collections');
    await userEvent.click(removeRadio);
  });

  await patientlyWaitFor(() => {
    const addRadio = getByLabelText('Add to host collections');
    const removeRadio = getByLabelText('Remove from host collections');

    expect(addRadio).not.toBeChecked();
    expect(removeRadio).toBeChecked();
  });

  assertNockRequest(hostCollectionsScope, false);
  assertNockRequest(autocompleteScope, false);
});

test('closes modal and clears selections on Cancel', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const hostCollectionsScope = nockInstance
    .get(hostCollectionsApiUrl)
    .query(true)
    .reply(200, mockHostCollections)
    .persist();

  const closeModal = jest.fn();

  const { getAllByRole } = renderWithRedux(
    <BulkChangeHostCollectionsModal
      {...defaultProps}
      closeModal={closeModal}
    />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    const cancelButton = getAllByRole('button', { name: 'Cancel' })[0];
    expect(cancelButton).toBeInTheDocument();
  });

  await act(async () => {
    const cancelButton = getAllByRole('button', { name: 'Cancel' })[0];
    userEvent.click(cancelButton);
  });

  expect(closeModal).toHaveBeenCalled();
  assertNockRequest(hostCollectionsScope, false);
  assertNockRequest(autocompleteScope, false);
});

test('does not fetch data when modal is closed', () => {
  const { queryByText } = renderWithRedux(
    <BulkChangeHostCollectionsModal
      {...defaultProps}
      isOpen={false}
    />,
    renderOptions(),
  );

  expect(queryByText('Change host collections')).not.toBeInTheDocument();
});

test('shows success toast notification on successful save', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const hostCollectionsScope = nockInstance
    .get(hostCollectionsApiUrl)
    .query(true)
    .reply(200, mockHostCollections)
    .persist();

  const saveScope = nockInstance
    .put('/api/v2/hosts/bulk/add_host_collections')
    .reply(200, { displayMessages: ['Host collections updated'] });

  const hostsRefreshScope = nockInstance
    .get('/api/hosts')
    .query(true)
    .reply(200, { results: [] });

  const { getAllByRole, getByText } = renderWithRedux(
    <BulkChangeHostCollectionsModal {...defaultProps} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    expect(getByText('Test Host Collection 1')).toBeInTheDocument();
  });

  // Simulate selecting a host collection
  let checkboxes;
  await act(async () => {
    checkboxes = getAllByRole('checkbox');
    // Click first host collection checkbox (skip the select all checkbox)
    await userEvent.click(checkboxes[1]);
  });

  // Save button should be enabled now
  await patientlyWaitFor(() => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    expect(saveButton).toHaveAttribute('aria-disabled', 'false');
  });

  // Click Save
  await act(async () => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    await userEvent.click(saveButton);
  });

  await patientlyWaitFor(() => {
    expect(addToast).toHaveBeenCalledWith(expect.objectContaining({ type: 'success' }));
  });

  assertNockRequest(saveScope, false);
  assertNockRequest(hostsRefreshScope, false);
  assertNockRequest(hostCollectionsScope, false);
  assertNockRequest(autocompleteScope, false);
});

// Test for error toast notification
test('shows error toast notification on failed save', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const hostCollectionsScope = nockInstance
    .get(hostCollectionsApiUrl)
    .query(true)
    .reply(200, mockHostCollections)
    .persist();

  const saveScope = nockInstance
    .put('/api/v2/hosts/bulk/add_host_collections')
    .reply(500, { error: { message: 'Internal Server Error' } });

  const { getAllByRole, getByText } = renderWithRedux(
    <BulkChangeHostCollectionsModal {...defaultProps} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    expect(getByText('Test Host Collection 1')).toBeInTheDocument();
  });

  // Simulate selecting a host collection
  let checkboxes;
  await act(async () => {
    checkboxes = getAllByRole('checkbox');
    // Click first host collection checkbox (skip the select all checkbox)
    await userEvent.click(checkboxes[1]);
  });

  // Save button should be enabled now
  await patientlyWaitFor(() => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    expect(saveButton).toHaveAttribute('aria-disabled', 'false');
  });

  // Click Save
  await act(async () => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    await userEvent.click(saveButton);
  });

  await patientlyWaitFor(() => {
    expect(addToast).toHaveBeenCalledWith(expect.objectContaining({ type: 'danger' }));
  });

  assertNockRequest(saveScope, false);
  assertNockRequest(hostCollectionsScope, false);
  assertNockRequest(autocompleteScope, false);
});

// Test for Add action API call
test('makes correct API call when Add action is selected', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const hostCollectionsScope = nockInstance
    .get(hostCollectionsApiUrl)
    .query(true)
    .reply(200, mockHostCollections)
    .persist();

  const saveScope = nockInstance
    .put('/api/v2/hosts/bulk/add_host_collections')
    .reply(200, { displayMessages: ['Host collections updated'] });

  const hostsRefreshScope = nockInstance
    .get('/api/hosts')
    .query(true)
    .reply(200, { results: [] });

  const { getAllByRole, getByText, getByLabelText } = renderWithRedux(
    <BulkChangeHostCollectionsModal {...defaultProps} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    expect(getByText('Test Host Collection 1')).toBeInTheDocument();
  });

  // Ensure Add radio is selected (default)
  const addRadio = getByLabelText('Add to host collections');
  expect(addRadio).toBeChecked();

  // Select a host collection
  let checkboxes;
  await act(async () => {
    checkboxes = getAllByRole('checkbox');
    await userEvent.click(checkboxes[1]);
  });

  // Click Save
  await act(async () => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    await userEvent.click(saveButton);
  });

  // Verify the API call was made and wait for all async operations
  await act(async () => {
    await patientlyWaitFor(() => {
      assertNockRequest(saveScope);
      expect(addToast).toHaveBeenCalled();
    });
  });

  assertNockRequest(hostCollectionsScope, false);
  assertNockRequest(autocompleteScope, false);
  assertNockRequest(hostsRefreshScope, false);
});

// Test for Remove action API call
test('makes correct API call when Remove action is selected', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const hostCollectionsScope = nockInstance
    .get(hostCollectionsApiUrl)
    .query(true)
    .reply(200, mockHostCollections)
    .persist();

  const saveScope = nockInstance
    .put('/api/v2/hosts/bulk/remove_host_collections')
    .reply(200, { displayMessages: ['Host collections updated'] });

  const hostsRefreshScope = nockInstance
    .get('/api/hosts')
    .query(true)
    .reply(200, { results: [] });

  const { getAllByRole, getByText, getByLabelText } = renderWithRedux(
    <BulkChangeHostCollectionsModal {...defaultProps} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    expect(getByText('Test Host Collection 2')).toBeInTheDocument();
  });

  // Select Remove radio button
  await act(async () => {
    const removeRadio = getByLabelText('Remove from host collections');
    await userEvent.click(removeRadio);
  });

  await patientlyWaitFor(() => {
    const removeRadio = getByLabelText('Remove from host collections');
    expect(removeRadio).toBeChecked();
  });

  // Select a different host collection (2nd one)
  let checkboxes;
  await act(async () => {
    checkboxes = getAllByRole('checkbox');
    await userEvent.click(checkboxes[2]); // Select 2nd host collection
  });

  // Click Save
  await act(async () => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    await userEvent.click(saveButton);
  });

  // Verify the API call was made to remove endpoint and wait for all async operations
  await act(async () => {
    await patientlyWaitFor(() => {
      assertNockRequest(saveScope);
      expect(addToast).toHaveBeenCalled();
    });
  });

  assertNockRequest(hostCollectionsScope, false);
  assertNockRequest(autocompleteScope, false);
  assertNockRequest(hostsRefreshScope, false);
});

// Test for multiple host collections selected
test('makes correct API call with multiple host collections', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const hostCollectionsScope = nockInstance
    .get(hostCollectionsApiUrl)
    .query(true)
    .reply(200, mockHostCollections)
    .persist();

  const saveScope = nockInstance
    .put('/api/v2/hosts/bulk/add_host_collections')
    .reply(200, { displayMessages: ['Host collections updated'] });

  const hostsRefreshScope = nockInstance
    .get('/api/hosts')
    .query(true)
    .reply(200, { results: [] });

  const { getAllByRole, getByText } = renderWithRedux(
    <BulkChangeHostCollectionsModal {...defaultProps} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    expect(getByText('Test Host Collection 1')).toBeInTheDocument();
  });

  // Select all three host collections
  let checkboxes;
  await act(async () => {
    checkboxes = getAllByRole('checkbox');
    await userEvent.click(checkboxes[1]); // First HC
    await userEvent.click(checkboxes[2]); // Second HC
    await userEvent.click(checkboxes[3]); // Third HC
  });

  // Click Save
  await act(async () => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    await userEvent.click(saveButton);
  });

  // Verify the API call includes all selected host collection IDs and wait for all async operations
  await act(async () => {
    await patientlyWaitFor(() => {
      assertNockRequest(saveScope);
      expect(addToast).toHaveBeenCalled();
    });
  });

  assertNockRequest(hostCollectionsScope, false);
  assertNockRequest(autocompleteScope, false);
  assertNockRequest(hostsRefreshScope, false);
});

const emptyHostCollections = {
  total: 0,
  subtotal: 0,
  page: 1,
  per_page: 5,
  results: [],
};

test('shows empty state with create button and disables Remove radio when no host collections exist', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const hostCollectionsScope = nockInstance
    .get(hostCollectionsApiUrl)
    .query(true)
    .reply(200, emptyHostCollections)
    .persist();

  const { getByText, getByLabelText, queryByText } = renderWithRedux(
    <BulkChangeHostCollectionsModal {...defaultProps} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    expect(getByText('No host collections yet')).toBeInTheDocument();
    expect(getByText('To get started, create a host collection.')).toBeInTheDocument();
    expect(getByText('Create host collection')).toBeInTheDocument();
    expect(queryByText('No Results')).not.toBeInTheDocument();

    const removeRadio = getByLabelText('Remove from host collections');
    expect(removeRadio).toBeDisabled();
  });

  assertNockRequest(hostCollectionsScope, false);
  assertNockRequest(autocompleteScope, false);
});

test('Remove radio is enabled when host collections exist', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const hostCollectionsScope = nockInstance
    .get(hostCollectionsApiUrl)
    .query(true)
    .reply(200, mockHostCollections)
    .persist();

  const { getByLabelText, getByText } = renderWithRedux(
    <BulkChangeHostCollectionsModal {...defaultProps} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    expect(getByText('Test Host Collection 1')).toBeInTheDocument();
    const removeRadio = getByLabelText('Remove from host collections');
    expect(removeRadio).not.toBeDisabled();
  });

  assertNockRequest(hostCollectionsScope, false);
  assertNockRequest(autocompleteScope, false);
});

test('shows default No Results when search returns empty', async () => {
  const emptySearchResponse = {
    total: 0,
    subtotal: 0,
    page: 1,
    per_page: 5,
    search: 'name ~ nonexistent',
    results: [],
  };

  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const hostCollectionsScope = nockInstance
    .get(hostCollectionsApiUrl)
    .query(true)
    .reply(200, emptySearchResponse)
    .persist();

  const { getByText, queryByText } = renderWithRedux(
    <BulkChangeHostCollectionsModal {...defaultProps} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    expect(getByText('No Results')).toBeInTheDocument();
    expect(queryByText('No host collections yet')).not.toBeInTheDocument();
    expect(queryByText('Create host collection')).not.toBeInTheDocument();
  });

  assertNockRequest(hostCollectionsScope, false);
  assertNockRequest(autocompleteScope, false);
});
