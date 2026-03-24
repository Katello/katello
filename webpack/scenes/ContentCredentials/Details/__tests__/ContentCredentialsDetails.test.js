import React from 'react';
import PropTypes from 'prop-types';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { MemoryRouter, Route } from 'react-router-dom';
import ContentCredentialsDetails from '../ContentCredentialsDetails';
import api from '../../../../services/api';
import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';

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
  organization: { id: 1, name: 'Default Organization' },
  gpg_key_products: [
    { id: 1, name: 'Test Product 1', cp_id: 'prod1' },
    { id: 2, name: 'Another Product', cp_id: 'prod2' },
  ],
  ssl_ca_products: [
    { id: 3, name: 'SSL Product', cp_id: 'ssl1' },
  ],
  ssl_client_products: [],
  ssl_key_products: [],
  gpg_key_repos: [
    {
      id: 1,
      name: 'Test Repository',
      content_type: 'yum',
      product: { id: 1, name: 'Test Product 1' }
    },
    {
      id: 2,
      name: 'Another Repo',
      content_type: 'docker',
      product: { id: 2, name: 'Another Product' }
    },
  ],
  ssl_ca_root_repos: [
    {
      id: 3,
      name: 'SSL Repository',
      content_type: 'yum',
      product: { id: 3, name: 'SSL Product' }
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

