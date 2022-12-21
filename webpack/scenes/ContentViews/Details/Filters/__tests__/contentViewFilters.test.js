import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { Route } from 'react-router-dom';

import api from '../../../../../services/api';
import { nockInstance, assertNockRequest, mockAutocomplete } from '../../../../../test-utils/nockWrapper';
import ContentViewFilters from '../ContentViewFilters';
import CONTENT_VIEWS_KEY from '../../../ContentViewsConstants';
import cvFilterFixtures from './contentViewFilters.fixtures.json';
import details from '../../../__tests__/mockDetails.fixtures.json';
import emptyContentViewFiltersData from './emptyContentViewFilters.fixtures.json';

const withCVRoute = component =>
  <Route path="/content_views/:id([0-9]+)#/filters">{component}</Route>;

const renderOptions = {
  apiNamespace: `${CONTENT_VIEWS_KEY}_1`,
  routerParams: {
    initialEntries: [{ pathname: '/content_views/1#/filters' }],
    initialIndex: 1,
  },
};


const cvFilters = api.getApiUrl('/content_view_filters');
const autocompleteUrl = '/content_view_filters/auto_complete_search';

let firstFilter;
let lastFilter;
beforeEach(() => {
  const { results } = cvFilterFixtures;
  [firstFilter] = results;
  [lastFilter] = results.slice(-1);
});

test('Can call API and show filters on page load', async (done) => {
  const { name, description } = firstFilter;
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const scope = nockInstance
    .get(cvFilters)
    .query(true)
    .reply(200, cvFilterFixtures);

  const { getByText, queryByText } =
    renderWithRedux(withCVRoute(<ContentViewFilters cvId={1} details={details} />), renderOptions);

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
  const autocompleteQuery = {
    organization_id: 1,
    search: '',
  };
  const searchQueryMatcher = {
    organization_id: 1,
    search: 'name = f5',
  };
  const searchResults = [
    {
      completed: 'name = f5',
      part: 'and',
      label: 'name = f5 and',
      category: 'Operators',
    },
    {
      completed: 'name = f5',
      part: 'or',
      label: 'name = f5 or',
      category: 'Operators',
    },
  ];
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const withSearchScope = mockAutocomplete(
    nockInstance,
    autocompleteUrl,
    searchQueryMatcher,
    searchResults,
  );
  const initialScope = nockInstance
    .get(cvFilters)
    .query(true)
    .reply(200, cvFilterFixtures);

  const { queryByText, getByLabelText, getByText } = renderWithRedux(
    withCVRoute(<ContentViewFilters cvId={1} details={details} />),
    renderOptions,
  );

  // Looking for description because the name is in the search bar and could match
  await patientlyWaitFor(() => {
    expect(getByText(description)).toBeInTheDocument();
    expect(getByText(name)).toBeInTheDocument();
    expect(getByText('f5')).toBeInTheDocument();
  });
  // Search for a filter by name
  getByLabelText('Search input').focus();
  fireEvent.change(getByLabelText('Search input'), { target: { value: `name = ${lastFilter.name}` } });
  // Only the first filter should be showing, not the last one
  await patientlyWaitFor(() => {
    expect(getByText(`name = ${lastFilter.name} and`)).toBeInTheDocument();
    expect(queryByText(`name = ${name} and`)).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(initialScope);
  assertNockRequest(withSearchScope, done);
});

test('Can remove a filter', async (done) => {
  const { id } = firstFilter;
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const getContentViewScope = nockInstance
    .get(cvFilters)
    .query(true)
    .reply(200, cvFilterFixtures);

  const removeFilterScope = nockInstance
    .delete(api.getApiUrl(`/content_view_filters/${id}`))
    .query(true)
    .reply(200, {});

  const callbackGetContentViewScope = nockInstance
    .get(cvFilters)
    .query(true)
    .reply(200, {});

  const { getAllByLabelText, getByText } = renderWithRedux(
    withCVRoute(<ContentViewFilters cvId={1} details={details} />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'false');
  });
  fireEvent.click(getAllByLabelText('Actions')[0]);
  expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'true');
  await patientlyWaitFor(() => expect(getByText('Remove')).toBeInTheDocument());
  fireEvent.click(getByText('Remove'));

  assertNockRequest(autocompleteScope);
  assertNockRequest(getContentViewScope);
  assertNockRequest(removeFilterScope);
  assertNockRequest(callbackGetContentViewScope, done);
});

test('Can remove multiple filters', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const getContentViewScope = nockInstance
    .get(cvFilters)
    .query(true)
    .reply(200, cvFilterFixtures);

  const removeFilterScope = nockInstance
    .put(
      api.getApiUrl('/content_views/1/remove_filters'),
      { filter_ids: [1, 4, 6, 7, 8, 9] },
    )
    .reply(200, {});

  const callbackGetContentViewScope = nockInstance
    .get(cvFilters)
    .query(true)
    .reply(200, {});

  const { getAllByLabelText, getByLabelText, getByText } = renderWithRedux(
    withCVRoute(<ContentViewFilters cvId={1} details={details} />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    fireEvent.click(getByLabelText('Select all rows'));
    expect(getAllByLabelText('bulk_actions')[0]).toHaveAttribute('aria-expanded', 'false');
  });
  fireEvent.click(getAllByLabelText('bulk_actions')[0]);
  expect(getAllByLabelText('bulk_actions')[0]).toHaveAttribute('aria-expanded', 'true');
  await patientlyWaitFor(() => expect(getByText('Remove')).toBeInTheDocument());
  fireEvent.click(getByText('Remove'));

  assertNockRequest(autocompleteScope);
  assertNockRequest(getContentViewScope);
  assertNockRequest(removeFilterScope);
  assertNockRequest(callbackGetContentViewScope, done);
});

test('Shows call-to-action button when there are no filters', async (done) => {
  const repoTypesResponse = [{ name: 'deb' }, { name: 'docker' }, { name: 'file' }, { name: 'ostree' }, { name: 'yum' }];
  const repoTypeScope = nockInstance
    .get(api.getApiUrl('/repositories/repository_types'))
    .query(true)
    .reply(200, repoTypesResponse);

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const scope = nockInstance
    .get(cvFilters)
    .query(true)
    .reply(200, emptyContentViewFiltersData);

  const { queryByLabelText } =
    renderWithRedux(withCVRoute(<ContentViewFilters cvId={1} details={details} />), renderOptions);

  expect(queryByLabelText('create_filter_empty_state')).toBeNull();
  await patientlyWaitFor(() => {
    expect(queryByLabelText('create_filter_empty_state')).toBeInTheDocument();
  });
  fireEvent.click(queryByLabelText('create_filter_empty_state'));
  await patientlyWaitFor(() => {
    expect(queryByLabelText('create_filter')).toBeInTheDocument();
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(repoTypeScope);
  assertNockRequest(scope, done);
});
