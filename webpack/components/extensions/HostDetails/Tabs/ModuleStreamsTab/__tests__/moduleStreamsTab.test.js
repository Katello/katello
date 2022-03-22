import React from 'react';
import { act } from 'react-test-renderer';
import { renderWithRedux, patientlyWaitFor, within, fireEvent } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockForemanAutocomplete, mockSetting } from '../../../../../../test-utils/nockWrapper';
import { foremanApi } from '../../../../../../services/api';
import { ModuleStreamsTab } from '../ModuleStreamsTab';
import mockModuleStreams from './modules.fixtures.json';
import { MODULE_STREAMS_KEY } from '../ModuleStreamsConstants';
import mockBookmarkData from '../../__tests__/bookmarks.fixtures.json';

const moduleBookmarks = foremanApi.getApiUrl('/bookmarks?search=controller%3Dkatello_host_available_module_streams');

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
let searchDelayScope;
let autoSearchScope;
let bookmarkScope;

beforeEach(() => {
  const { results } = mockModuleStreams;
  [firstModuleStreams] = results;
  bookmarkScope = nockInstance.get(moduleBookmarks).reply(200, mockBookmarkData);
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 0);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing');
});

afterEach(() => {
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
  assertNockRequest(bookmarkScope);
});

beforeEach(() => {
  const { results } = mockModuleStreams;
  [firstModuleStreams] = results;
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 0);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing');
});

afterEach(() => {
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
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
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
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
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
  act(done);
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
  assertNockRequest(scope2, done);
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
  assertNockRequest(scope2, done);
  act(done);
});
