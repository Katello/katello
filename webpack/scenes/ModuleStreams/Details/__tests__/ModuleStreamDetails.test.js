import React from 'react';
import { Route } from 'react-router-dom';
import { renderWithRedux, patientlyWaitFor, act } from 'react-testing-lib-wrapper';
import nock from 'nock';
import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';
import ModuleStreamDetails from '../index';
import { details } from './moduleStreamDetails.fixtures';

// Mock LoadingState to avoid memory leak warnings from setTimeout
jest.mock('../../../../components/LoadingState', () => ({
  // eslint-disable-next-line react/prop-types
  LoadingState: ({ loading, children }) => (
    loading ? <div>Loading...</div> : <>{children}</>
  ),
}));

// Mock BreadcrumbsBar as it's an external Foreman component
jest.mock('foremanReact/components/BreadcrumbBar', () => ({
  __esModule: true,
  // eslint-disable-next-line react/prop-types
  default: ({ breadcrumbItems }) => (
    <div>
      {breadcrumbItems.map(item => (
        <span key={item.caption}>{item.caption}</span>
      ))}
    </div>
  ),
}));

const moduleStreamId = 22;
const moduleStreamPath = api.getApiUrl(`/module_streams/${moduleStreamId}`);

const getInitialState = () => ({
  katello: {
    moduleStreamDetails: {
      loading: true,
    },
  },
});

const withRoute = component => (
  <Route path="/module_streams/:id">{component}</Route>
);

describe('Module Stream Details Page', () => {
  afterEach(() => {
    nock.cleanAll();
  });

  test('loads and displays module stream details', async (done) => {
    const scope = nockInstance
      .get(moduleStreamPath)
      .query(true)
      .reply(200, details);

    const { getByText, queryByText } = renderWithRedux(
      withRoute(<ModuleStreamDetails />),
      {
        routerParams: {
          initialEntries: [{ pathname: `/module_streams/${moduleStreamId}` }],
        },
        apiState: getInitialState(),
      },
    );

    // Initially loading
    expect(queryByText('Loading...')).toBeInTheDocument();

    // Wait for data to load
    await patientlyWaitFor(() => {
      // Breadcrumb displays module stream name and stream
      expect(getByText('Module Streams')).toBeInTheDocument();
      expect(getByText('avocado latest')).toBeInTheDocument();

      // Tab headers are visible
      expect(getByText('Details')).toBeInTheDocument();
      expect(getByText('Repositories')).toBeInTheDocument();
      expect(getByText('Profiles')).toBeInTheDocument();
      expect(getByText('Artifacts')).toBeInTheDocument();
    });

    assertNockRequest(scope);
    act(done);
  });

  test('displays module stream details content in Details tab', async (done) => {
    const scope = nockInstance
      .get(moduleStreamPath)
      .query(true)
      .reply(200, details);

    const { getByText } = renderWithRedux(
      withRoute(<ModuleStreamDetails />),
      {
        routerParams: {
          initialEntries: [{ pathname: `/module_streams/${moduleStreamId}` }],
        },
        apiState: getInitialState(),
      },
    );

    await patientlyWaitFor(() => {
      // Verify key details are displayed
      expect(getByText('avocado')).toBeInTheDocument();
      expect(getByText('latest')).toBeInTheDocument();
      expect(getByText('Framework with tools and libraries for Automated Testing')).toBeInTheDocument();
      expect(getByText(/Avocado is a set of tools and libraries/)).toBeInTheDocument();
      expect(getByText('20180816135607')).toBeInTheDocument();
      expect(getByText('a5b0195c')).toBeInTheDocument();
      expect(getByText('x86_64')).toBeInTheDocument();
      expect(getByText('8ae7f190-0a48-41a2-93e0-7bc3e4734355')).toBeInTheDocument();
    });

    assertNockRequest(scope);
    act(done);
  });

  test('displays repository information', async (done) => {
    const scope = nockInstance
      .get(moduleStreamPath)
      .query(true)
      .reply(200, details);

    const { getByText, container } = renderWithRedux(
      withRoute(<ModuleStreamDetails />),
      {
        routerParams: {
          initialEntries: [{ pathname: `/module_streams/${moduleStreamId}` }],
        },
        apiState: getInitialState(),
      },
    );

    await patientlyWaitFor(() => {
      // Click on Repositories tab
      const repoTab = getByText('Repositories');
      repoTab.click();
    });

    // Verify repository names are displayed
    await patientlyWaitFor(() => {
      expect(getByText('rawhide_wtih_modules')).toBeInTheDocument();
      expect(getByText('rawhide_wtih_modules_dup')).toBeInTheDocument();

      // Verify product column exists and contains fedora entries in active tab
      const activePane = container.querySelector('.tab-pane.active');
      const table = activePane.querySelector('table');
      const rows = table.querySelectorAll('tbody tr');
      expect(rows).toHaveLength(2);

      // Both rows should have fedora as the product
      rows.forEach((row) => {
        const cells = row.querySelectorAll('td');
        expect(cells[1]).toHaveTextContent('fedora');
      });
    });

    assertNockRequest(scope);
    act(done);
  });

  test('displays profile information', async (done) => {
    const scope = nockInstance
      .get(moduleStreamPath)
      .query(true)
      .reply(200, details);

    const { getByText } = renderWithRedux(
      withRoute(<ModuleStreamDetails />),
      {
        routerParams: {
          initialEntries: [{ pathname: `/module_streams/${moduleStreamId}` }],
        },
        apiState: getInitialState(),
      },
    );

    await patientlyWaitFor(() => {
      // Click on Profiles tab
      const profilesTab = getByText('Profiles');
      profilesTab.click();
    });

    // Verify profile names are displayed
    await patientlyWaitFor(() => {
      expect(getByText('default')).toBeInTheDocument();
      expect(getByText('minimal')).toBeInTheDocument();
    });

    assertNockRequest(scope);
    act(done);
  });

  test('displays artifacts information', async (done) => {
    const scope = nockInstance
      .get(moduleStreamPath)
      .query(true)
      .reply(200, details);

    const { getByText } = renderWithRedux(
      withRoute(<ModuleStreamDetails />),
      {
        routerParams: {
          initialEntries: [{ pathname: `/module_streams/${moduleStreamId}` }],
        },
        apiState: getInitialState(),
      },
    );

    await patientlyWaitFor(() => {
      // Click on Artifacts tab
      const artifactsTab = getByText('Artifacts');
      artifactsTab.click();
    });

    // Verify artifacts are displayed
    await patientlyWaitFor(() => {
      expect(getByText('python3-avocado-plugins-varianter-yaml-to-mux-0:63.0-2.module_2037+1b0ad681.noarch')).toBeInTheDocument();
      expect(getByText('python3-avocado-plugins-varianter-pict-0:63.0-2.module_2037+1b0ad681.noarch')).toBeInTheDocument();
    });

    assertNockRequest(scope);
    act(done);
  });

  test('renders loading state initially', () => {
    const { getByText } = renderWithRedux(
      withRoute(<ModuleStreamDetails />),
      {
        routerParams: {
          initialEntries: [{ pathname: `/module_streams/${moduleStreamId}` }],
        },
        apiState: getInitialState(),
      },
    );

    expect(getByText('Loading...')).toBeInTheDocument();
  });
});
