import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import nock, { nockInstance, assertNockRequest, mockAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import CONTENT_VIEWS_KEY from '../../../ContentViewsConstants';
import ContentViewComponents from '../ContentViewComponents';

const cvComponentData = require('./contentViewComponents.fixtures.json');
const cvUnpublishedComponentData = require('./unpublishedCVComponents.fixtures.json');

const renderOptions = { apiNamespace: `${CONTENT_VIEWS_KEY}_1` };
const cvComponents = api.getApiUrl('/content_views/5/content_view_components');
const autocompleteUrl = '/content_views/auto_complete_search';

let firstComponent;
let searchDelayScope;
let autoSearchScope;

beforeEach(() => {
  const { results } = cvComponentData;
  [firstComponent] = results;
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', true);
});

afterEach(() => {
  nock.cleanAll();
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
});

test('Can call API and show components on page load', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvComponents)
    .query(true)
    .reply(200, cvComponentData);

  const { getByText, queryByText } = renderWithRedux(
    <ContentViewComponents cvId={5} />,
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(firstComponent.content_view.label)).toBeNull();
  // Assert that the repo name is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => expect(getByText(firstComponent.content_view.label)).toBeTruthy());
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Can call API and show unpublished components', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvComponents)
    .query(true)
    .reply(200, cvUnpublishedComponentData);

  const unpublishedComponent = cvUnpublishedComponentData.results[1];

  const { getByText, queryByText, getAllByText } = renderWithRedux(
    <ContentViewComponents cvId={5} />,
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(unpublishedComponent.content_view.label)).toBeNull();
  // Assert that the repo name is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(getByText(unpublishedComponent.content_view.label)).toBeTruthy();
    expect(getAllByText('Not yet published')).toHaveLength(4);
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Can link to view environment', async () => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvComponents)
    .query(true)
    .reply(200, cvComponentData);

  const { getAllByText } = renderWithRedux(
    <ContentViewComponents cvId={5} />,
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(getAllByText('Library')[0].closest('a'))
      .toHaveAttribute('href', '/lifecycle_environments/1');
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
});

test('Can search for component content views in component view', async (done) => {
  const lastComponent = cvComponentData.results[1];
  const { name: firstComponentName } = firstComponent.content_view;
  const { name: lastComponentName } = lastComponent.content_view;
  const searchQueryMatcher = actualParams => actualParams?.search?.includes(lastComponentName);

  const cvComponentsScope = nockInstance
    .get(cvComponents)
    .query(true)
    .reply(200, cvComponentData);
  const cvComponentsSearchScope = nockInstance
    .get(cvComponents)
    .query(searchQueryMatcher)
    .reply(200, { results: [lastComponent] });

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const withSearchScope = mockAutocomplete(nockInstance, autocompleteUrl, searchQueryMatcher);
  const { getByText, queryByText, getByLabelText } =
    renderWithRedux(<ContentViewComponents cvId={5} />, renderOptions);

  // Basic results showing
  await patientlyWaitFor(() => {
    expect(getByText(firstComponentName)).toBeInTheDocument();
    expect(getByText(lastComponentName)).toBeInTheDocument();
  });

  // Search and only searched result shows
  const searchInput = getByLabelText(/text input for search/i);
  expect(searchInput).toBeInTheDocument();
  fireEvent.change(searchInput, { target: { value: `name = "${lastComponentName}"` } });

  await patientlyWaitFor(() => {
    expect(getByText(lastComponentName)).toBeInTheDocument();
    expect(queryByText(firstComponentName)).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvComponentsScope);
  assertNockRequest(withSearchScope);
  assertNockRequest(cvComponentsSearchScope, done);
});

test('Can handle no components being present', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const noResults = {
    total: 0,
    subtotal: 0,
    page: 1,
    per_page: 20,
    results: [],
  };
  const scope = nockInstance
    .get(cvComponents)
    .query(true)
    .reply(200, noResults);

  const mockDetails = { label: 'test_empty' };
  const { queryByText } =
    renderWithRedux(<ContentViewComponents cvId={5} details={mockDetails} />, renderOptions);

  expect(queryByText(firstComponent.content_view.label)).toBeNull();
  await patientlyWaitFor(() => expect(queryByText('No content views belong to test_empty')).toBeTruthy());
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});
