import React from 'react';
import { renderWithRedux, patientlyWaitFor, act } from 'react-testing-lib-wrapper';
import nock from 'nock';
import { nockInstance, assertNockRequest, mockAutocomplete } from '../../../test-utils/nockWrapper';
import api from '../../../services/api';
import ModuleStreamsPage from '../index';
import moduleStreamsData from './moduleStreams.fixtures.json';

// Mock LoadingState to avoid memory leak warnings
jest.mock('../../../components/LoadingState', () => ({
  __esModule: true,
  // eslint-disable-next-line react/prop-types
  LoadingState: ({ loading, children }) => (
    loading ? <div>Loading...</div> : <>{children}</>
  ),
}));

const moduleStreamsPath = api.getApiUrl('/module_streams');
const autocompleteUrl = '/module_streams/auto_complete_search';
const autocompleteQuery = {
  organization_id: 1,
  search: '',
};

const getInitialState = () => ({
  katello: {
    moduleStreams: {
      loading: true,
      results: [],
      pagination: { page: 0 },
      itemCount: 0,
    },
  },
});

afterEach(() => {
  nock.cleanAll();
});

describe('Module streams page', () => {
  test('loads and displays module streams from API', async (done) => {
    const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
    const scope = nockInstance
      .get(moduleStreamsPath)
      .query(true)
      .reply(200, moduleStreamsData);

    const { getByText, queryByText, getAllByText } = renderWithRedux(
      <ModuleStreamsPage />,
      getInitialState(),
    );

    // Should not show data before loading
    expect(queryByText('postgresql')).toBeNull();
    expect(queryByText('ruby')).toBeNull();

    // Assert that module streams are showing on screen after API call
    await patientlyWaitFor(() => {
      // Page header
      expect(getByText('Module Streams')).toBeInTheDocument();

      // Table column headers
      expect(getByText('Name')).toBeInTheDocument();
      expect(getByText('Stream')).toBeInTheDocument();
      expect(getByText('Version')).toBeInTheDocument();
      expect(getByText('Context')).toBeInTheDocument();
      expect(getByText('Arch')).toBeInTheDocument();

      // Verify multiple module stream names are displayed
      expect(getByText('postgresql')).toBeInTheDocument();
      expect(getByText('ruby')).toBeInTheDocument();
      expect(getByText('nodejs')).toBeInTheDocument();
      expect(getByText('python36')).toBeInTheDocument();
      expect(getByText('mariadb')).toBeInTheDocument();

      // Verify stream versions are displayed
      expect(getByText('10')).toBeInTheDocument(); // postgresql stream
      expect(getByText('2.5')).toBeInTheDocument(); // ruby stream
      expect(getByText('12')).toBeInTheDocument(); // nodejs stream
      expect(getByText('3.6')).toBeInTheDocument(); // python36 stream
      expect(getByText('10.3')).toBeInTheDocument(); // mariadb stream

      // Verify versions are displayed
      expect(getByText('20180629154141')).toBeInTheDocument();
      expect(getByText('20180726175620')).toBeInTheDocument();

      // Verify contexts are displayed
      expect(getByText('819b5873')).toBeInTheDocument();
      expect(getByText('6c81f848')).toBeInTheDocument();

      // Verify architecture (appears multiple times in the table)
      const archElements = getAllByText('x86_64');
      expect(archElements.length).toBeGreaterThan(0);
    });

    assertNockRequest(autocompleteScope);
    assertNockRequest(scope);
    act(done);
  });

  test('displays empty state when no module streams exist', async (done) => {
    const noResults = {
      total: 0,
      subtotal: 0,
      page: 1,
      per_page: 20,
      results: [],
    };

    const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
    const scope = nockInstance
      .get(moduleStreamsPath)
      .query(true)
      .reply(200, noResults);

    const { queryByText } = renderWithRedux(
      <ModuleStreamsPage />,
      getInitialState(),
    );

    await patientlyWaitFor(() => {
      expect(queryByText(/no content found/i)).toBeInTheDocument();
    });

    assertNockRequest(autocompleteScope);
    assertNockRequest(scope);
    act(done);
  });

  test('handles API error gracefully', async (done) => {
    const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
    const scope = nockInstance
      .get(moduleStreamsPath)
      .query(true)
      .reply(500);

    const { queryByText } = renderWithRedux(
      <ModuleStreamsPage />,
      getInitialState(),
    );

    await patientlyWaitFor(() => {
      expect(queryByText(/no content found/i)).toBeInTheDocument();
    });

    assertNockRequest(autocompleteScope);
    assertNockRequest(scope);
    act(done);
  });
});
