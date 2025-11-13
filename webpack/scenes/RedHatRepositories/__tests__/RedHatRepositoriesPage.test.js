import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import nock from 'nock';

import RedHatRepositoriesPage from '../index';
import api from '../../../services/api';
import { nockInstance, assertNockRequest } from '../../../test-utils/nockWrapper';

import organizationData from './organization.fixtures.json';
import organizationExportSyncData from './organizationExportSync.fixtures.json';
import repositorySetsData from './repositorySets.fixtures.json';
import enabledRepositoriesData from './enabledRepositories.fixtures.json';

// Mock external Foreman components
jest.mock('foremanReact/components/PermissionDenied', () => ({
  __esModule: true,
  default: ({ missingPermissions }) => (
    <div data-testid="permission-denied">
      Permission denied: {missingPermissions.join(', ')}
    </div>
  ),
}));

// Mock Pagination to avoid extra API calls
jest.mock('foremanReact/components/Pagination', () => ({
  __esModule: true,
  default: ({ itemCount }) => (
    <div data-testid="pagination">Pagination - {itemCount} items</div>
  ),
}));

// Mock legacy components that use jQuery
jest.mock('../components/SearchBar', () => ({
  __esModule: true,
  default: () => <div data-testid="search-bar">Search Bar</div>,
}));

jest.mock('../components/RecommendedRepositorySetsToggler', () => ({
  __esModule: true,
  default: ({ enabled, onChange }) => (
    <div data-testid="recommended-toggler">
      Recommended Repositories
      <input
        type="checkbox"
        checked={enabled}
        onChange={e => onChange(e.target.checked)}
        aria-label="Recommended repositories toggle"
      />
    </div>
  ),
}));

// Mock RepositorySet and EnabledRepository to avoid complex child component behavior
jest.mock('../components/RepositorySet', () => ({
  __esModule: true,
  default: ({ name, id }) => (
    <div data-testid={`repository-set-${id}`}>{name}</div>
  ),
}));

jest.mock('../components/EnabledRepository', () => ({
  __esModule: true,
  default: ({ name, id }) => (
    <div data-testid={`enabled-repository-${id}`}>{name}</div>
  ),
}));

// Mock LoadingState to avoid setTimeout memory leak warnings in tests
jest.mock('../../../components/LoadingState', () => ({
  __esModule: true,
  // eslint-disable-next-line react/prop-types
  LoadingState: ({ loading, children }) => (loading ? <div>Loading...</div> : children),
}));

const organizationPath = api.getApiUrl('/organizations/1');
const repositoriesPath = api.getApiUrl('/repositories');
const repositorySetsPath = api.getApiUrl('/repository_sets');

const getInitialState = () => ({
  katello: {
    redHatRepositories: {
      enabled: {
        loading: true,
        repositories: [],
        pagination: {
          page: 0,
        },
        itemCount: 0,
      },
      sets: {
        loading: true,
        recommended: false,
        results: [],
        pagination: {
          page: 0,
        },
        itemCount: 0,
      },
    },
    organization: {
      loading: false,
    },
  },
});

describe('RedHatRepositories page', () => {
  afterEach(() => {
    nock.cleanAll();
  });

  test('loads and renders page with Red Hat CDN configuration', async () => {
    const orgScope = nockInstance
      .get(organizationPath)
      .query(true)
      .reply(200, organizationData);

    const reposScope = nockInstance
      .get(repositoriesPath)
      .query(true)
      .reply(200, enabledRepositoriesData);

    const setsScope = nockInstance
      .get(repositorySetsPath)
      .query(true)
      .reply(200, repositorySetsData);

    const { getByText, queryByText } = renderWithRedux(
      <RedHatRepositoriesPage />,
      getInitialState(),
    );

    // Should not show content initially
    expect(queryByText('Red Hat Repositories')).toBeNull();

    await patientlyWaitFor(() => {
      // Verify main heading
      expect(getByText('Red Hat Repositories')).toBeInTheDocument();

      // Verify Available Repositories section
      expect(getByText('Available Repositories')).toBeInTheDocument();

      // Verify Enabled Repositories section
      expect(getByText('Enabled Repositories')).toBeInTheDocument();

      // Verify Export CSV button appears
      expect(getByText('Export as CSV')).toBeInTheDocument();

      // Verify Search Bar is rendered
      expect(queryByText('Search Bar')).toBeInTheDocument();

      // Verify no Export Sync alert is shown
      expect(queryByText(/CDN configuration is set to Export Sync/i)).not.toBeInTheDocument();
    });

    assertNockRequest(orgScope);
    assertNockRequest(reposScope);
    assertNockRequest(setsScope);
  });

  test('displays repository sets data when loaded', async () => {
    const orgScope = nockInstance
      .get(organizationPath)
      .query(true)
      .reply(200, organizationData);

    const reposScope = nockInstance
      .get(repositoriesPath)
      .query(true)
      .reply(200, enabledRepositoriesData);

    const setsScope = nockInstance
      .get(repositorySetsPath)
      .query(true)
      .reply(200, repositorySetsData);

    const { getByText } = renderWithRedux(
      <RedHatRepositoriesPage />,
      getInitialState(),
    );

    await patientlyWaitFor(() => {
      // Verify repository set names appear (using actual fixture data)
      expect(getByText(/Red Hat Enterprise Linux 8 for x86_64 - BaseOS \(RPMs\)/i)).toBeInTheDocument();
    });

    assertNockRequest(orgScope);
    assertNockRequest(reposScope);
    assertNockRequest(setsScope);
  });

  test('displays enabled repositories data when loaded', async () => {
    const orgScope = nockInstance
      .get(organizationPath)
      .query(true)
      .reply(200, organizationData);

    const reposScope = nockInstance
      .get(repositoriesPath)
      .query(true)
      .reply(200, enabledRepositoriesData);

    const setsScope = nockInstance
      .get(repositorySetsPath)
      .query(true)
      .reply(200, repositorySetsData);

    const { getByText } = renderWithRedux(
      <RedHatRepositoriesPage />,
      getInitialState(),
    );

    await patientlyWaitFor(() => {
      // Verify enabled repository names appear (using actual fixture data)
      expect(getByText(/Red Hat Enterprise Linux 8 for x86_64 - BaseOS RPMs 8/i)).toBeInTheDocument();
    });

    assertNockRequest(orgScope);
    assertNockRequest(reposScope);
    assertNockRequest(setsScope);
  });

  test('shows Export Sync alert for disconnected CDN configuration', async () => {
    const orgScope = nockInstance
      .get(organizationPath)
      .query(true)
      .reply(200, organizationExportSyncData);

    const reposScope = nockInstance
      .get(repositoriesPath)
      .query(true)
      .reply(200, enabledRepositoriesData);

    const setsScope = nockInstance
      .get(repositorySetsPath)
      .query(true)
      .reply(200, repositorySetsData);

    const { getByText, queryByText } = renderWithRedux(
      <RedHatRepositoriesPage />,
      getInitialState(),
    );

    await patientlyWaitFor(() => {
      // Verify main heading still appears
      expect(getByText('Red Hat Repositories')).toBeInTheDocument();

      // Verify Export Sync alert message
      expect(getByText(/CDN configuration is set to Export Sync \(disconnected\)/i)).toBeInTheDocument();
      expect(getByText(/Repository enablement\/disablement is not permitted on this page/i)).toBeInTheDocument();

      // Verify Available Repositories section does NOT appear
      expect(queryByText('Available Repositories')).not.toBeInTheDocument();

      // Verify Enabled Repositories section does NOT appear
      expect(queryByText('Enabled Repositories')).not.toBeInTheDocument();

      // Verify Export CSV button does NOT appear
      expect(queryByText('Export as CSV')).not.toBeInTheDocument();
    });

    assertNockRequest(orgScope);
    assertNockRequest(reposScope);
    assertNockRequest(setsScope);
  });

  test('shows permission denied when repositorySets permissions are missing', async () => {
    const errorResponse = {
      error: {
        message: 'Access denied',
        missing_permissions: ['view_products'],
      },
    };

    const orgScope = nockInstance
      .get(organizationPath)
      .query(true)
      .reply(200, organizationData);

    const reposScope = nockInstance
      .get(repositoriesPath)
      .query(true)
      .reply(200, enabledRepositoriesData);

    const setsScope = nockInstance
      .get(repositorySetsPath)
      .query(true)
      .reply(403, errorResponse);

    const { getByTestId, queryByText } = renderWithRedux(
      <RedHatRepositoriesPage />,
      getInitialState(),
    );

    await patientlyWaitFor(() => {
      // Verify permission denied component appears
      expect(getByTestId('permission-denied')).toBeInTheDocument();
      expect(getByTestId('permission-denied').textContent).toContain('view_products');

      // Verify main page content does NOT appear
      expect(queryByText('Red Hat Repositories')).not.toBeInTheDocument();
    });

    assertNockRequest(orgScope);
    assertNockRequest(reposScope);
    assertNockRequest(setsScope);
  });

  test('shows permission denied when enabledRepositories permissions are missing', async () => {
    const errorResponse = {
      error: {
        message: 'Access denied',
        missing_permissions: ['view_products', 'view_content_views'],
      },
    };

    const orgScope = nockInstance
      .get(organizationPath)
      .query(true)
      .reply(200, organizationData);

    const reposScope = nockInstance
      .get(repositoriesPath)
      .query(true)
      .reply(403, errorResponse);

    const setsScope = nockInstance
      .get(repositorySetsPath)
      .query(true)
      .reply(200, repositorySetsData);

    const { getByTestId, queryByText } = renderWithRedux(
      <RedHatRepositoriesPage />,
      getInitialState(),
    );

    await patientlyWaitFor(() => {
      // Verify permission denied component appears
      expect(getByTestId('permission-denied')).toBeInTheDocument();
      expect(getByTestId('permission-denied').textContent).toContain('view_products');
      expect(getByTestId('permission-denied').textContent).toContain('view_content_views');

      // Verify main page content does NOT appear
      expect(queryByText('Red Hat Repositories')).not.toBeInTheDocument();
    });

    assertNockRequest(orgScope);
    assertNockRequest(reposScope);
    assertNockRequest(setsScope);
  });

  test('shows skeleton while organization is loading', async () => {
    const initialOrgState = {
      ...getInitialState(),
      katello: {
        ...getInitialState().katello,
        organization: {
          loading: true, // Organization is still loading
        },
      },
    };

    const orgScope = nockInstance
      .get(organizationPath)
      .query(true)
      .delay(100)
      .reply(200, organizationData);

    const reposScope = nockInstance
      .get(repositoriesPath)
      .query(true)
      .reply(200, enabledRepositoriesData);

    const setsScope = nockInstance
      .get(repositorySetsPath)
      .query(true)
      .reply(200, repositorySetsData);

    const { queryByText, getByText } = renderWithRedux(
      <RedHatRepositoriesPage />,
      initialOrgState,
    );

    // Initially should show skeleton (loading state)
    expect(queryByText('Red Hat Repositories')).not.toBeInTheDocument();

    // Wait for organization to load and content to appear
    await patientlyWaitFor(() => {
      expect(getByText('Red Hat Repositories')).toBeInTheDocument();
    });

    assertNockRequest(orgScope);
    assertNockRequest(reposScope);
    assertNockRequest(setsScope);

    // Wait for LoadingState timeout to complete to avoid memory leak warnings
    await new Promise(resolve => setTimeout(resolve, 400));
  });

  test('handles empty repository sets', async () => {
    const emptyRepoSets = {
      total: 0,
      subtotal: 0,
      page: 1,
      per_page: 20,
      results: [],
    };

    const orgScope = nockInstance
      .get(organizationPath)
      .query(true)
      .reply(200, organizationData);

    const reposScope = nockInstance
      .get(repositoriesPath)
      .query(true)
      .reply(200, enabledRepositoriesData);

    const setsScope = nockInstance
      .get(repositorySetsPath)
      .query(true)
      .reply(200, emptyRepoSets);

    const { getByText } = renderWithRedux(
      <RedHatRepositoriesPage />,
      getInitialState(),
    );

    await patientlyWaitFor(() => {
      // When there are no repository sets but search is active, shows search empty message
      // Note: The Redux reducer sets searchIsActive when results come back from API call
      expect(getByText(/No repository sets match your search criteria/i)).toBeInTheDocument();
    });

    assertNockRequest(orgScope);
    assertNockRequest(reposScope);
    assertNockRequest(setsScope);
  });

  test('handles empty enabled repositories', async () => {
    const emptyEnabledRepos = {
      ...enabledRepositoriesData,
      total: 0,
      subtotal: 0,
      results: [],
    };

    const orgScope = nockInstance
      .get(organizationPath)
      .query(true)
      .reply(200, organizationData);

    const reposScope = nockInstance
      .get(repositoriesPath)
      .query(true)
      .reply(200, emptyEnabledRepos);

    const setsScope = nockInstance
      .get(repositorySetsPath)
      .query(true)
      .reply(200, repositorySetsData);

    const { getByText } = renderWithRedux(
      <RedHatRepositoriesPage />,
      getInitialState(),
    );

    await patientlyWaitFor(() => {
      // Verify empty state message for enabled repositories (using actual text from helpers.js)
      expect(getByText('No repositories enabled.')).toBeInTheDocument();
    });

    assertNockRequest(orgScope);
    assertNockRequest(reposScope);
    assertNockRequest(setsScope);
  });
});
