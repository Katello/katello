import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent, act } from 'react-testing-lib-wrapper';
import { Route } from 'react-router-dom';

import ContentViewFilterDetails from '../ContentViewFilterDetails';
import { cvFilterDetailsKey } from '../../../ContentViewsConstants';
import {
  nockInstance,
  assertNockRequest,
  mockAutocomplete,
} from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import allPackageGroups from './allFilterPackageGroups.fixtures.json';
import cvFilterDetails from './contentViewFilterDetail.fixtures.json';
import cvFilterFixtures from './contentViewFilters.fixtures.json';
import details from '../../../__tests__/mockDetails.fixtures.json';

const cvFiltersPath = api.getApiUrl('/content_view_filters');
const cvFilterDetailsPath = api.getApiUrl('/content_view_filters/1');
const packageGroupsPath = api.getApiUrl('/package_groups');
const autocompleteUrl = '/package_groups/auto_complete_search';
const renderOptions = {
  apiNamespace: cvFilterDetailsKey(1, 1),
  routerParams: {
    initialEntries: [{ pathname: '/content_views/2#/filters/1' }],
    initialIndex: 1,
  },
};
const autocompleteQuery = {
  filterid: 1,
  organization_id: 1,
  search: '',
};

const withCVRoute = component => <Route path="/content_views/:id([0-9]+)#/filters/:filterId([0-9]+)">{component}</Route>;

test('Can show filter details and package groups on page load', async (done) => {
  const { name: cvFilterName } = cvFilterDetails;
  const cvFilterScope = nockInstance
    .get(cvFilterDetailsPath)
    .query(true)
    .reply(200, cvFilterDetails);
  const cvFiltersScope = nockInstance
    .get(cvFiltersPath)
    .query(true)
    .reply(200, cvFilterFixtures);
  const packageGroupsScope = nockInstance
    .get(packageGroupsPath)
    .query(true)
    .reply(200, allPackageGroups);
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const { getByText, queryByText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(cvFilterName)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(cvFilterName)).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(packageGroupsScope, done);
  act(done);
});

test('Can search for package groups in package group filter', async (done) => {
  const firstPackageGroup = allPackageGroups.results[0];
  const lastPackageGroup = allPackageGroups.results.slice(-1)[0];
  const { name: cvFilterName } = cvFilterDetails;
  const { name: firstPackageGroupName } = firstPackageGroup;
  const { name: lastPackageGroupName } = lastPackageGroup;
  const searchQueryMatcher = {
    filterid: 1,
    organization_id: 1,
    search: `name = ${lastPackageGroupName}`,
  };
  const searchResults = [
    {
      completed: `name = ${lastPackageGroupName}`,
      part: 'and',
      label: `name = ${lastPackageGroupName} and`,
      category: 'Operators',
    },
    {
      completed: `name = ${lastPackageGroupName}`,
      part: 'or',
      label: `name = ${lastPackageGroupName} or`,
      category: 'Operators',
    },
  ];

  const cvFilterScope = nockInstance
    .get(cvFilterDetailsPath)
    .query(true)
    .reply(200, cvFilterDetails);
  const cvFiltersScope = nockInstance
    .get(cvFiltersPath)
    .query(true)
    .reply(200, cvFilterFixtures);
  const packageGroupsScope = nockInstance
    .get(packageGroupsPath)
    .query(true)
    .reply(200, allPackageGroups);
  const packageGroupSearchScope = nockInstance
    .get(packageGroupsPath)
    .query(searchQueryMatcher)
    .reply(200, { results: [lastPackageGroup] });

  const autocompleteScope =
    mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const withSearchScope = mockAutocomplete(
    nockInstance,
    autocompleteUrl,
    searchQueryMatcher,
    searchResults,
  );
  const { getByText, queryByText, getByLabelText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Basic results showing
  await patientlyWaitFor(() => {
    expect(getByText(cvFilterName)).toBeInTheDocument();
    expect(getByText(firstPackageGroupName)).toBeInTheDocument();
  });

  // Search and only searched result shows
  getByLabelText('Search input').focus();
  fireEvent.change(getByLabelText('Search input'), { target: { value: `name = ${lastPackageGroupName}` } });
  await patientlyWaitFor(() => {
    expect(getByText(`name = ${lastPackageGroupName} and`)).toBeInTheDocument();
    expect(queryByText(`name = ${firstPackageGroupName} and`)).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(packageGroupsScope);
  assertNockRequest(withSearchScope);
  assertNockRequest(packageGroupSearchScope, done);
  act(done);
});
