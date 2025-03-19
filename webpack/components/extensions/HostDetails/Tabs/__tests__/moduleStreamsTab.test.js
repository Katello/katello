import React from 'react';
import { act } from 'react-test-renderer';
import { renderWithRedux, patientlyWaitFor, within, fireEvent } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockForemanAutocomplete } from '../../../../../test-utils/nockWrapper';
import { ModuleStreamsTab } from '../ModuleStreamsTab/ModuleStreamsTab.js';
import mockModuleStreams from './moduleStreams.fixtures.json';
import { MODULE_STREAMS_KEY } from '../../../../../scenes/ModuleStreams/ModuleStreamsConstants';
import { foremanApi } from '../../../../../services/api';

jest.mock('../../hostDetailsHelpers', () => ({
  ...jest.requireActual('../../hostDetailsHelpers'),
  userPermissionsFromHostDetails: () => ({
    create_job_invocations: true,
  }),
}));

const contentFacetAttributes = {
  id: 11,
  uuid: 'e5761ea3-4117-4ecf-83d0-b694f99b389e',
  content_view_default: false,
  lifecycle_environment_library: false,
};

const renderOptions = (facetAttributes = contentFacetAttributes) => ({
  apiNamespace: MODULE_STREAMS_KEY,
  initialState: {
    API: {
      HOST_DETAILS: {
        response: {
          id: 1,
          name: 'test-host',
          content_facet_attributes: { ...facetAttributes },
        },
        status: 'RESOLVED',
      },
    },
  },
});

const hostModuleStreams = foremanApi.getApiUrl('/hosts/1/module_streams');
const autocompleteUrl = '/hosts/1/module_streams/auto_complete_search';

let firstModuleStreams;

beforeEach(() => {
  const { results } = mockModuleStreams;
  [firstModuleStreams] = results;
});

test('Can call API for Module streams and show on screen on page load', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostModuleStreams)
    .query(true)
    .reply(200, mockModuleStreams);

  const { getAllByText } = renderWithRedux(<ModuleStreamsTab />, renderOptions());

  // Assert that the Module streams are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() =>
    expect(getAllByText(firstModuleStreams.name)[0]).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  done(); // Pass jest callback to confirm test is done
  act(done);
});

test('Can handle no Module streams being present', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  const noResults = {
    total: 0,
    subtotal: 0,
    page: 1,
    per_page: 20,
    results: [],
  };

  const scope = nockInstance
    .get(hostModuleStreams)
    .query(true)
    .reply(200, noResults);

  const { queryByText } = renderWithRedux(<ModuleStreamsTab />, renderOptions());

  // Assert that there are not any Module streams showing on the screen.
  await patientlyWaitFor(() => expect(queryByText('This host does not have any Module streams.')).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  done(); // Pass jest callback to confirm test is done
  act(done);
});

test('When there are no search results, can display an empty state with a clear search link that works', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const noResults = {
    total: 0,
    subtotal: 0,
    page: 1,
    search: 'bad search',
    per_page: 20,
    results: [],
  };

  const initialScope = nockInstance
    .get(hostModuleStreams)
    .query(true)
    .times(1)
    .reply(200, mockModuleStreams);

  const badSearchScope = nockInstance
    .get(hostModuleStreams)
    .query({
      sort_by: 'name',
      sort_order: 'asc',
      per_page: '20',
      page: '1',
      search: 'bad search',
    })
    .reply(200, noResults);

  const badAutoCompleteScope =
    mockForemanAutocomplete(
      nockInstance,
      autocompleteUrl,
      true,
      [],
      2, // times
    );

  const scopeWithoutSearch = nockInstance
    .get(hostModuleStreams)
    .query(true)
    .reply(200, mockModuleStreams);

  const { queryByText, getByRole } = renderWithRedux(<ModuleStreamsTab />, renderOptions());


  await patientlyWaitFor(() => expect(queryByText(firstModuleStreams.name)).toBeInTheDocument());

  const searchInput = getByRole('textbox', { name: 'Search input' });
  // Foreman SearchAutocomplete doesn't run onSearchChange unless the element is focused!
  searchInput.focus();

  fireEvent.change(searchInput, { target: { value: 'bad search' } });
  expect(searchInput.value).toBe('bad search');
  const searchButton = getByRole('button', { name: 'Search' });
  expect(searchButton).not.toHaveAttribute('aria-disabled', true);
  fireEvent.click(searchButton);

  await patientlyWaitFor(() => expect(queryByText('Your search returned no matching Module streams.')).toBeInTheDocument());
  // Now click the clear search link and assert that the search is cleared and the results are back
  const clearSearchLink = getByRole('button', { name: 'Clear search' });
  fireEvent.click(clearSearchLink);

  await patientlyWaitFor(() => {
    expect(queryByText(firstModuleStreams.name)).toBeInTheDocument();
    expect(getByRole('textbox', { name: 'Search input' }).value).toBe('');
    expect(queryByText('Clear search')).not.toBeInTheDocument();
  });

  assertNockRequest(initialScope);
  assertNockRequest(badAutoCompleteScope);
  assertNockRequest(badSearchScope);
  assertNockRequest(scopeWithoutSearch);
  assertNockRequest(autocompleteScope);
  done();
});

test('Can filter results based on status', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostModuleStreams)
    .query(true)
    .reply(200, mockModuleStreams);

  const scope2 = nockInstance
    .get(hostModuleStreams)
    .query(true)
    .reply(200, mockModuleStreams);

  const {
    queryByLabelText,
    getByRole,
    getAllByText,
  } = renderWithRedux(<ModuleStreamsTab />, renderOptions());

  // Assert that the Module streams are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() =>
    expect(getAllByText(firstModuleStreams.name)[0]).toBeInTheDocument());
  const typeContainer = queryByLabelText('select Status container', { ignore: 'th' });
  const typeDropdown = within(typeContainer).queryByText('Status');
  expect(typeDropdown).toBeInTheDocument();
  fireEvent.click(typeDropdown);
  const installed = getByRole('option', { name: 'select Installed' });
  fireEvent.click(installed);
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(scope2);
  done();
  act(done);
});

test('Can filter results based on Installation status', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostModuleStreams)
    .query(true)
    .reply(200, mockModuleStreams);

  const scope2 = nockInstance
    .get(hostModuleStreams)
    .query(true)
    .reply(200, mockModuleStreams);

  const {
    queryByLabelText,
    getByRole,
    getAllByText,
  } = renderWithRedux(<ModuleStreamsTab />, renderOptions());

  // Assert that the Module streams are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() =>
    expect(getAllByText(firstModuleStreams.name)[0]).toBeInTheDocument());
  const typeContainer = queryByLabelText('select Installation status container', { ignore: 'th' });
  const typeDropdown = within(typeContainer).queryByText('Installation status');
  expect(typeDropdown).toBeInTheDocument();
  fireEvent.click(typeDropdown);
  const installed = getByRole('option', { name: 'select Upgradable' });
  fireEvent.click(installed);
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(scope2);
  done();
  act(done);
});

test('Can provide dropdown actions with redirects on Module Streams with customized Rex', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostModuleStreams)
    .query(true)
    .reply(200, mockModuleStreams);

  const {
    queryByLabelText,
    getByText,
    getAllByText,
    getByLabelText,
  } = renderWithRedux(<ModuleStreamsTab />, renderOptions());

  // Assert that the Module streams are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() =>
    expect(getAllByText(firstModuleStreams.name)[0]).toBeInTheDocument());
  expect(queryByLabelText('kebab-dropdown-3')).toBeInTheDocument();
  fireEvent.click(queryByLabelText('kebab-dropdown-3'));
  await patientlyWaitFor(() => expect(getByLabelText('customize-checkbox-3')).toBeInTheDocument());
  fireEvent.click(getByLabelText('customize-checkbox-3'));
  await patientlyWaitFor(() => expect(getByText('Enable')).toBeInTheDocument());
  expect(getByText('Enable')).toHaveAttribute('href', '/job_invocations/new?feature=katello_module_stream_action&search=name%20%5E%20(test-host)&inputs%5Baction%5D=enable&inputs%5Bmodule_spec%5D=walrus:2.4');
  expect(getByText('Install')).toHaveAttribute('href', '/job_invocations/new?feature=katello_module_stream_action&search=name%20%5E%20(test-host)&inputs%5Baction%5D=install&inputs%5Bmodule_spec%5D=walrus:2.4');
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  done();
  act(done);
});

test('Can perform actions on Module Streams', async (done) => {
  const jobInvocationURL = foremanApi.getApiUrl('/job_invocations');
  const exampleRemoveAction = {
    job_invocation:
    {
      feature: 'katello_module_stream_action',
      inputs: {
        action: 'remove',
        module_spec: 'walrus:2.4',
      },
      search_query: 'name ^ (test-host)',
    },
  };
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostModuleStreams)
    .query(true)
    .reply(200, mockModuleStreams);

  const jobScope = nockInstance
    .post(jobInvocationURL, exampleRemoveAction)
    .reply(200, { id: 'dummy_id', description: 'Remove action dummy response' });

  const {
    queryByLabelText,
    getByText,
    getAllByText,
    getByLabelText,
  } = renderWithRedux(<ModuleStreamsTab />, renderOptions());

  // Assert that the Module streams are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() =>
    expect(getAllByText(firstModuleStreams.name)[0]).toBeInTheDocument());
  expect(queryByLabelText('kebab-dropdown-3')).toBeInTheDocument();
  fireEvent.click(queryByLabelText('kebab-dropdown-3'));
  await patientlyWaitFor(() => expect(getByText('Enable')).toBeInTheDocument());
  fireEvent.click(getByText('Remove'));
  expect(getByLabelText('confirm-module-action')).toBeInTheDocument();
  fireEvent.click(getByLabelText('confirm-module-action'));
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(jobScope);
  done();
  act(done);
});
