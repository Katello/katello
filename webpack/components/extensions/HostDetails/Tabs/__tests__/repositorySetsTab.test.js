import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import katelloApi, { foremanApi } from '../../../../../services/api';
import { REPOSITORY_SETS_KEY } from '../RepositorySetsTab/RepositorySetsConstants';
import RepositorySetsTab from '../RepositorySetsTab/RepositorySetsTab';
import mockRepoSetData from './repositorySets.fixtures.json';
import mockBookmarkData from './bookmarks.fixtures.json';
import mockContentOverride from './contentOverrides.fixtures.json';

const contentFacetAttributes = {
  id: 11,
  uuid: 'e5761ea3-4117-4ecf-83d0-b694f99b389e',
  content_view_default: false,
  lifecycle_environment_library: false,
};

const renderOptions = (facetAttributes = contentFacetAttributes) => ({
  apiNamespace: REPOSITORY_SETS_KEY,
  initialState: {
    API: {
      HOST_DETAILS: {
        response: {
          id: 1,
          content_facet_attributes: { ...facetAttributes },
          subscription_status: 5, // Simple Content Access
        },
        status: 'RESOLVED',
      },
    },
  },
});

const hostRepositorySets = katelloApi.getApiUrl('/repository_sets');
const autocompleteUrl = '/repository_sets/auto_complete_search';
const repositorySetBookmarks = foremanApi.getApiUrl('/bookmarks?search=controller%3Dkatello_product_contents');
const contentOverride = foremanApi.getApiUrl('/hosts/1/subscriptions/content_override');

const limitToEnvQuery = {
  content_access_mode_env: true,
  content_access_mode_all: true,
  host_id: 1,
  per_page: 20,
  page: 1,
  search: '',
};
const showAllQuery = {
  ...limitToEnvQuery,
  content_access_mode_env: false,
};

let firstRepoSet;
let searchDelayScope;
let autoSearchScope;
let bookmarkScope;

beforeEach(() => {
  // jest.resetModules();
  const { results } = mockRepoSetData;
  [firstRepoSet] = results;
  bookmarkScope = nockInstance.get(repositorySetBookmarks).reply(200, mockBookmarkData);
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 0);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing');
});

afterEach(() => {
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
  assertNockRequest(bookmarkScope);
});

test('Can call API for repository sets and show basic table', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostRepositorySets)
    .query(limitToEnvQuery)
    .reply(200, mockRepoSetData);

  const { getByText } = renderWithRedux(<RepositorySetsTab />, renderOptions());

  // Assert that the repository sets are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getByText(firstRepoSet.contentUrl)).toBeInTheDocument());
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Can handle no repository sets being present', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const noResults = {
    total: 0,
    subtotal: 0,
    page: 1,
    per_page: 20,
    results: [],
  };

  const scope = nockInstance
    .get(hostRepositorySets)
    .query(limitToEnvQuery)
    .reply(200, noResults);

  const { queryByText } = renderWithRedux(<RepositorySetsTab />, renderOptions());

  // Assert that there are not any repository sets showing on the screen.
  await patientlyWaitFor(() => expect(queryByText('No repository sets to show.')).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Toggle Group shows if it\'s not the default content view or library enviroment', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostRepositorySets)
    .query(limitToEnvQuery)
    .reply(200, mockRepoSetData);

  const {
    queryByLabelText,
    getByText,
  } = renderWithRedux(<RepositorySetsTab />, renderOptions());

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getByText(firstRepoSet.contentUrl)).toBeInTheDocument());
  expect(queryByLabelText('Limit to environment')).toBeInTheDocument();
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Toggle Group shows if it\'s the default content view but non-library environment', async (done) => {
  const options = renderOptions({
    ...contentFacetAttributes,
    content_view_default: true,
  });
  // Setup autocomplete with mockAutocomplete since we aren't adding /katello
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostRepositorySets)
    .query(limitToEnvQuery)
    .reply(200, mockRepoSetData);

  const {
    queryByLabelText,
    getByText,
  } = renderWithRedux(<RepositorySetsTab />, options);

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getByText(firstRepoSet.contentUrl)).toBeInTheDocument());
  expect(queryByLabelText('Limit to environment')).toBeInTheDocument();
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Toggle Group shows if it\'s the library environment but a non-default content view', async (done) => {
  const options = renderOptions({
    ...contentFacetAttributes,
    lifecycle_environment_library: true,
  });
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  // return errata data results when we look for errata
  const scope = nockInstance
    .get(hostRepositorySets)
    .query(limitToEnvQuery)
    .reply(200, mockRepoSetData);

  const {
    queryByLabelText,
    getByText,
  } = renderWithRedux(<RepositorySetsTab />, options);

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getByText(firstRepoSet.contentUrl)).toBeInTheDocument());
  expect(queryByLabelText('Limit to environment')).toBeInTheDocument();
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Toggle Group does not show if it\'s the library environment and default content view', async (done) => {
  const options = renderOptions({
    ...contentFacetAttributes,
    lifecycle_environment_library: true,
    content_view_default: true,
  });
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  // return errata data results when we look for errata
  const scope = nockInstance
    .get(hostRepositorySets)
    .query(showAllQuery)
    .reply(200, mockRepoSetData);

  const {
    queryByLabelText,
    getByText,
  } = renderWithRedux(<RepositorySetsTab />, options);

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getByText(firstRepoSet.contentUrl)).toBeInTheDocument());
  expect(queryByLabelText('Limit to environment')).not.toBeInTheDocument();
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Can toggle with the Toggle Group ', async (done) => {
  // Setup autocomplete with mockAutocomplete since we aren't adding /katello
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  // return errata data results when we look for errata
  const scope = nockInstance
    .get(hostRepositorySets)
    .query(limitToEnvQuery)
    .reply(200, mockRepoSetData);

  const {
    queryByLabelText,
    getByText,
  } = renderWithRedux(<RepositorySetsTab />, renderOptions());

  await patientlyWaitFor(() => expect(getByText(firstRepoSet.contentUrl)).toBeInTheDocument());
  expect(queryByLabelText('Limit to environment')).toBeInTheDocument();
  expect(queryByLabelText('Limit to environment')).toHaveAttribute('aria-pressed', 'true');
  expect(queryByLabelText('No limit')).toHaveAttribute('aria-pressed', 'false');
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Can override to disabled', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostRepositorySets)
    .query(limitToEnvQuery)
    .reply(200, mockRepoSetData);
  const contentOverrideScope = nockInstance
    .put(contentOverride)
    .reply(200, mockContentOverride);

  const { getByText, getAllByText, getAllByLabelText } =
    renderWithRedux(<RepositorySetsTab />, renderOptions());

  // Assert that the repository sets are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getByText(firstRepoSet.contentUrl)).toBeInTheDocument());
  expect(getAllByText('Enabled')).toHaveLength(2);
  expect(getAllByText('Disabled')).toHaveLength(1);
  // Find the first action menu and click it
  const actionMenu = getAllByLabelText('Actions')[0].closest('button');
  fireEvent.click(actionMenu);

  const overrideMenuItem = getByText('Override to disabled');
  expect(overrideMenuItem).toBeInTheDocument();
  fireEvent.click(overrideMenuItem);

  await patientlyWaitFor(() => {
    expect(getAllByText('Enabled')).toHaveLength(1);
    expect(getAllByText('Disabled')).toHaveLength(2);
  });


  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(contentOverrideScope, done); // Pass jest callback to confirm test is done
});

test('Can override to enabled', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostRepositorySets)
    .query(limitToEnvQuery)
    .reply(200, mockRepoSetData);
  const contentOverrideScope = nockInstance
    .put(contentOverride)
    .reply(200, mockContentOverride);

  const {
    getByText, queryByText, getAllByText, getAllByLabelText,
  } = renderWithRedux(<RepositorySetsTab />, renderOptions());

  // Assert that the repository sets are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getByText(firstRepoSet.contentUrl)).toBeInTheDocument());
  expect(getAllByText('Enabled')).toHaveLength(2);
  expect(getAllByText('Disabled')).toHaveLength(1);
  // The second item is overridden to disabled; we're going to override to enabled
  const actionMenu = getAllByLabelText('Actions')[1].closest('button');
  fireEvent.click(actionMenu);

  const overrideMenuItem = getByText('Override to enabled');
  expect(overrideMenuItem).toBeInTheDocument();
  fireEvent.click(overrideMenuItem);

  await patientlyWaitFor(() => {
    expect(getAllByText('Enabled')).toHaveLength(3);
    expect(queryByText('Disabled')).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(contentOverrideScope, done); // Pass jest callback to confirm test is done
});

test('Can reset to default', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostRepositorySets)
    .query(limitToEnvQuery)
    .reply(200, mockRepoSetData);
  const contentOverrideScope = nockInstance
    .put(contentOverride)
    .reply(200, mockContentOverride);

  const {
    getByText, queryByText, getAllByText, getAllByLabelText,
  } = renderWithRedux(<RepositorySetsTab />, renderOptions());

  // Assert that the repository sets are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getByText(firstRepoSet.contentUrl)).toBeInTheDocument());
  expect(getAllByText('Enabled')).toHaveLength(2);
  expect(getAllByText('Disabled')).toHaveLength(1);
  // The second item is overridden to disabled but would normally be enabled; we're going to reset
  const actionMenu = getAllByLabelText('Actions')[1].closest('button');
  fireEvent.click(actionMenu);

  const overrideMenuItem = getByText('Reset to default');
  expect(overrideMenuItem).toBeInTheDocument();
  fireEvent.click(overrideMenuItem);

  await patientlyWaitFor(() => {
    expect(getAllByText('Enabled')).toHaveLength(3);
    expect(queryByText('Disabled')).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(contentOverrideScope, done); // Pass jest callback to confirm test is done
});
