import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';

import api from '../../../../../services/api';
import nock, { nockInstance, assertNockRequest, mockAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import ContentViewFilters from '../ContentViewFilters';
import CONTENT_VIEWS_KEY from '../../../ContentViewsConstants';

const cvFilterFixtures = require('./contentViewFilters.fixtures.json');

const cvFilters = api.getApiUrl('/content_view_filters');
const autocompleteUrl = '/content_view_filters/auto_complete_search';
const renderOptions = { apiNamespace: `${CONTENT_VIEWS_KEY}_1` };

let firstFilter;
let lastFilter;
let searchDelayScope;
let autoSearchScope;
beforeEach(() => {
  const { results } = cvFilterFixtures;
  [firstFilter] = results;
  [lastFilter] = results.slice(-1);
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
  // Autosearch can cause some asynchronous issues with the typing timeout, using basic search
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', false);
});

afterEach(() => {
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
  nock.cleanAll();
});

test('Can call API and show filters on page load', async (done) => {
  const { name, description } = firstFilter;
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const scope = nockInstance
    .get(cvFilters)
    .query(true)
    .reply(200, cvFilterFixtures);

  const { getByText, queryByText } =
    renderWithRedux(<ContentViewFilters cvId={1} />, renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(name)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getByText(name)).toBeInTheDocument();
    expect(getByText(description)).toBeInTheDocument();
    expect(getByText(lastFilter.name)).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Can search for filter', async (done) => {
  const { name, description } = firstFilter;
  const searchQueryMatcher = actualParams => actualParams?.search?.includes(name);
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const withSearchScope = mockAutocomplete(nockInstance, autocompleteUrl, searchQueryMatcher);
  const initialScope = nockInstance
    .get(cvFilters)
    .query(true)
    .reply(200, cvFilterFixtures);
  const searchResultScope = nockInstance
    .get(cvFilters)
    .query(searchQueryMatcher)
    .reply(200, { results: [firstFilter] });

  const { queryByText, getByLabelText, getByText } = renderWithRedux(
    <ContentViewFilters cvId={1} />,
    renderOptions,
  );

  // Looking for description because the name is in the search bar and could match
  await patientlyWaitFor(() => expect(getByText(description)).toBeInTheDocument());
  // Search for a filter by name
  fireEvent.change(getByLabelText(/text input for search/i), { target: { value: name } });
  getByLabelText(/search button/i).click();
  // Only the first filter should be showing, not the last one
  await patientlyWaitFor(() => {
    expect(getByText(description)).toBeInTheDocument();
    expect(queryByText(lastFilter.name)).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(withSearchScope);
  assertNockRequest(initialScope);
  assertNockRequest(searchResultScope, done);
});
