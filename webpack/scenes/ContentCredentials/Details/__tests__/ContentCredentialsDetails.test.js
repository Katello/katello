import React from 'react';
import PropTypes from 'prop-types';
import { screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { MemoryRouter, Route } from 'react-router-dom';
import { addToast } from 'foremanReact/components/ToastsList';
import ContentCredentialsDetails from '../ContentCredentialsDetails';
import api from '../../../../services/api';
import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';

jest.mock('foremanReact/components/ToastsList', () => ({
  addToast: jest.fn(() => ({ type: 'ADD_TOAST' })),
}));

const credentialId = 1;
const credentialDetailsPath = api.getApiUrl(`/content_credentials/${credentialId}`);

const withCredentialRoute = component => (
  <Route path="/labs/content_credentials/:id([0-9]+)">{component}</Route>
);

const renderOptions = {
  apiNamespace: 'CONTENT_CREDENTIAL_DETAILS',
  routerParams: {
    initialEntries: [{ pathname: `/labs/content_credentials/${credentialId}` }],
  },
};

const mockCredentialData = {
  id: credentialId,
  name: 'Test GPG Key',
  content_type: 'gpg_key',
  content: '-----BEGIN PGP PUBLIC KEY BLOCK-----\ntest content\n-----END PGP PUBLIC KEY BLOCK-----',
  organization_id: 1,
  organization: { id: 1, name: 'Default Organization', label: 'Default_Organization' },
  created_at: '2026-03-24 16:16:57 -0400',
  updated_at: '2026-04-02 13:02:30 -0400',
  gpg_key_products: [
    { id: 1, name: 'Test Product 1', cp_id: 'prod1', repository_count: 2, provider: { id: 1, name: 'Red Hat' } },
    { id: 2, name: 'Another Product', cp_id: 'prod2', repository_count: 1, provider: { id: 2, name: 'Custom' } },
  ],
  ssl_ca_products: [
    { id: 3, name: 'SSL Product', cp_id: 'ssl1', repository_count: 1, provider: { id: 1, name: 'Red Hat' } },
  ],
  ssl_client_products: [],
  ssl_key_products: [],
  gpg_key_repos: [
    {
      id: 1,
      name: 'Test Repository',
      content_type: 'yum',
      library_instance_id: 101,
      product: { id: 1, name: 'Test Product 1', cp_id: 'prod1' },
    },
    {
      id: 2,
      name: 'Another Repo',
      content_type: 'docker',
      library_instance_id: 102,
      product: { id: 2, name: 'Another Product', cp_id: 'prod2' },
    },
  ],
  ssl_ca_root_repos: [
    {
      id: 3,
      name: 'SSL Repository',
      content_type: 'yum',
      library_instance_id: 103,
      product: { id: 3, name: 'SSL Product', cp_id: 'ssl1' },
    },
  ],
  ssl_client_root_repos: [],
  ssl_key_root_repos: [],
  ssl_ca_alternate_content_sources: [
    { id: 1, name: 'Test ACS 1' },
    { id: 2, name: 'Another ACS' },
  ],
  ssl_client_alternate_content_sources: [],
  ssl_key_alternate_content_sources: [],
  permissions: {
    edit_content_credentials: true,
  },
};

const TestWrapper = ({ children }) => (
  <MemoryRouter initialEntries={[`/labs/content_credentials/${credentialId}`]}>
    {withCredentialRoute(children)}
  </MemoryRouter>
);

TestWrapper.propTypes = {
  children: PropTypes.node.isRequired,
};

test('Can load content credential details and display name', async () => {
  const scope = nockInstance
    .get(credentialDetailsPath)
    .query(true)
    .reply(200, mockCredentialData);

  const { queryByText } = renderWithRedux(
    withCredentialRoute(<ContentCredentialsDetails />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(queryByText('Test GPG Key (GPG Key)')).toBeInTheDocument();
  });

  assertNockRequest(scope);
});

test('Displays Details tab with correct content type', async () => {
  const scope = nockInstance
    .get(credentialDetailsPath)
    .query(true)
    .reply(200, mockCredentialData);

  const { queryByText } = renderWithRedux(
    withCredentialRoute(<ContentCredentialsDetails />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(queryByText('GPG Key')).toBeInTheDocument();
    expect(queryByText('Details')).toBeInTheDocument();
  });

  assertNockRequest(scope);
});

test('Displays all expected tabs', async () => {
  const scope = nockInstance
    .get(credentialDetailsPath)
    .query(true)
    .reply(200, mockCredentialData);

  const { container } = renderWithRedux(
    withCredentialRoute(<ContentCredentialsDetails />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    // Check for tab navigation specifically
    const tabsContainer = container.querySelector('.pf-v5-c-tabs');
    expect(tabsContainer).toBeInTheDocument();
    expect(tabsContainer.textContent).toContain('Details');
    expect(tabsContainer.textContent).toContain('Products');
    expect(tabsContainer.textContent).toContain('Repositories');
    expect(tabsContainer.textContent).toContain('Alternate content sources');
  });

  assertNockRequest(scope);
});

test('opens delete modal from kebab menu and confirms deletion', async () => {
  const getScope = nockInstance
    .get(credentialDetailsPath)
    .query(true)
    .reply(200, mockCredentialData);

  const deleteScope = nockInstance
    .delete(credentialDetailsPath)
    .reply(200, {});

  const { getByLabelText, getByText, queryByText } = renderWithRedux(
    withCredentialRoute(<ContentCredentialsDetails />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(queryByText('Test GPG Key (GPG Key)')).toBeInTheDocument();
  });

  // Open kebab menu
  fireEvent.click(getByLabelText('Kebab toggle'));

  // Click Delete from dropdown
  fireEvent.click(getByText('Delete'));

  // Modal should appear with confirmation message
  await patientlyWaitFor(() => {
    expect(queryByText('Delete Content Credential')).toBeInTheDocument();
    expect(queryByText(/Are you sure you want to delete content credential/)).toBeInTheDocument();
  });

  // Confirm deletion
  fireEvent.click(getByText('Delete', { selector: '[data-ouia-component-id="delete-confirm-button"]' }));

  assertNockRequest(getScope);
  assertNockRequest(deleteScope);
});

test('cancel button closes delete modal without deleting', async () => {
  const getScope = nockInstance
    .get(credentialDetailsPath)
    .query(true)
    .reply(200, mockCredentialData);

  const { getByLabelText, getByText, queryByText } = renderWithRedux(
    withCredentialRoute(<ContentCredentialsDetails />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(queryByText('Test GPG Key (GPG Key)')).toBeInTheDocument();
  });

  // Open kebab menu and click Delete
  fireEvent.click(getByLabelText('Kebab toggle'));
  fireEvent.click(getByText('Delete'));

  await patientlyWaitFor(() => {
    expect(queryByText('Delete Content Credential')).toBeInTheDocument();
  });

  // Click Cancel
  fireEvent.click(getByText('Cancel'));

  // Modal should close
  await patientlyWaitFor(() => {
    expect(queryByText('Delete Content Credential')).not.toBeInTheDocument();
  });

  assertNockRequest(getScope);
});

test('shows error toast when delete fails', async () => {
  const getScope = nockInstance
    .get(credentialDetailsPath)
    .query(true)
    .reply(200, mockCredentialData);

  const deleteScope = nockInstance
    .delete(credentialDetailsPath)
    .reply(422, {
      displayMessage: 'Cannot delete credential in use',
    });

  const { getByLabelText, getByText, queryByText } = renderWithRedux(
    withCredentialRoute(<ContentCredentialsDetails />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(queryByText('Test GPG Key (GPG Key)')).toBeInTheDocument();
  });

  // Open kebab menu and click Delete
  fireEvent.click(getByLabelText('Kebab toggle'));
  fireEvent.click(getByText('Delete'));

  await patientlyWaitFor(() => {
    expect(queryByText('Delete Content Credential')).toBeInTheDocument();
  });

  // Confirm deletion
  fireEvent.click(getByText('Delete', { selector: '[data-ouia-component-id="delete-confirm-button"]' }));

  // Wait for the error toast to be dispatched
  await patientlyWaitFor(() => {
    expect(addToast).toHaveBeenCalledWith(expect.objectContaining({
      type: 'danger',
    }));
  });

  assertNockRequest(getScope);
  assertNockRequest(deleteScope);
});

test('Displays loading state while fetching credential details', () => {
  nockInstance
    .get(credentialDetailsPath)
    .query(true)
    .delay(1000)
    .reply(200, mockCredentialData);

  const { getByText, queryByText } = renderWithRedux(
    withCredentialRoute(<ContentCredentialsDetails />),
    renderOptions,
  );

  // Loading indicator should be visible immediately
  expect(getByText('Loading')).toBeInTheDocument();

  // Content should not be rendered yet
  expect(queryByText('Test GPG Key (GPG Key)')).not.toBeInTheDocument();
  expect(queryByText('Details')).not.toBeInTheDocument();
});

test('Transitions from loading state to content when data loads', async () => {
  const scope = nockInstance
    .get(credentialDetailsPath)
    .query(true)
    .reply(200, mockCredentialData);

  const { getByText, queryByText } = renderWithRedux(
    withCredentialRoute(<ContentCredentialsDetails />),
    renderOptions,
  );

  // Initially shows loading
  expect(getByText('Loading')).toBeInTheDocument();

  // After data loads, content replaces loading indicator
  await patientlyWaitFor(() => {
    expect(queryByText('Loading')).not.toBeInTheDocument();
    expect(queryByText('Test GPG Key (GPG Key)')).toBeInTheDocument();
  });

  assertNockRequest(scope);
});

test('Tabs are not rendered during loading state', () => {
  nockInstance
    .get(credentialDetailsPath)
    .query(true)
    .delay(1000)
    .reply(200, mockCredentialData);

  const { container, queryByText } = renderWithRedux(
    withCredentialRoute(<ContentCredentialsDetails />),
    renderOptions,
  );

  // Loading indicator should be visible
  expect(queryByText('Loading')).toBeInTheDocument();

  // Tabs should not be rendered while loading
  const tabsContainer = container.querySelector('.pf-v5-c-tabs');
  expect(tabsContainer).not.toBeInTheDocument();
});

test('renders error empty state when loading credential details fails', async () => {
  const scope = nockInstance
    .get(credentialDetailsPath)
    .query(true)
    .reply(500);

  const { queryByText } = renderWithRedux(
    withCredentialRoute(<ContentCredentialsDetails />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    // Main layout should not be visible
    expect(queryByText('Test GPG Key (GPG Key)')).not.toBeInTheDocument();
    expect(queryByText('Details')).not.toBeInTheDocument();

    // Error empty state should be visible
    // NOTE: This checks for the actual error message shown by EmptyStateMessage
    expect(queryByText(/something went wrong/i)).toBeInTheDocument();
  });

  assertNockRequest(scope);
});

