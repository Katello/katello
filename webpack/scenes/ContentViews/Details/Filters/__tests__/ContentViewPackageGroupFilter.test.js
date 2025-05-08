import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent, act } from 'react-testing-lib-wrapper';
import { Route } from 'react-router-dom';

import ContentViewFilterDetails from '../ContentViewFilterDetails';
import { ADDED, cvFilterDetailsKey, NOT_ADDED } from '../../../ContentViewsConstants';
import nock, {
  nockInstance,
  assertNockRequest,
  mockAutocomplete,
} from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';

import allPackageGroups from './allFilterPackageGroups.fixtures.json';
import cvFilterDetails from './contentViewFilterDetail.fixtures.json';
import cvFilterDetailsAffectedRepos from './cvFilterDetailWithAffectedRepos.fixtures.json';
import cvFilterFixtures from './contentViewFilters.fixtures.json';
import cvAllRepos from './cvAllRepos.fixtures.json';
import details from '../../../__tests__/mockDetails.fixtures.json';

const cvRefreshCallbackPath = api.getApiUrl('/content_views/1');
const cvFiltersPath = api.getApiUrl('/content_view_filters');

const cvAddFilterRulePath = api.getApiUrl('/content_view_filters/1/rules');
const cvRemoveFilterRulePath = api.getApiUrl('/content_view_filters/1/rules/1');
const cvFilterDetailsPath = api.getApiUrl('/content_view_filters/1');
const cvBulkRemoveFilterRulesPath = api.getApiUrl('/content_view_filters/1/remove_filter_rules');
const cvBulkAddFilterRulesPath = api.getApiUrl('/content_view_filters/1/add_filter_rules');
const cvGetAllReposPath = api.getApiUrl('/content_views/1/repositories');

const autocompleteUrl = '/package_groups/auto_complete_search';
const autocompleteQuery = {
  filterid: 1,
  organization_id: 1,
  search: '',
};

const packageGroupsPath = api.getApiUrl('/package_groups');
const renderOptions = {
  apiNamespace: cvFilterDetailsKey(1, 1),
  routerParams: {
    initialEntries: [{ pathname: '/content_views/1#/filters/1' }],
    initialIndex: 1,
  },
};

const withCVRoute = component => <Route path="/content_views/:id([0-9]+)#/filters/:filterId([0-9]+)">{component}</Route>;

afterEach(() => {
  nock.cleanAll(); // Removes all interceptors
  nock.restore(); // Restores HTTP to normal behavior
});

test('Can enable and disable add filter button', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
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

  const { getByText, queryByText, getByLabelText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(cvFilterName)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(cvFilterName)).toBeInTheDocument();
    expect(getByLabelText('Select all rows')).toBeInTheDocument();
  });
  expect(getByLabelText('add_filter_rule')).toHaveAttribute('aria-disabled', 'true');
  getByLabelText('Select all rows').click();
  await patientlyWaitFor(() => {
    expect(getByLabelText('add_filter_rule')).toHaveAttribute('aria-disabled', 'false');
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(packageGroupsScope, done);
  act(done);
});

test('Can remove a filter rule', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const { rules } = cvFilterDetails;
  const { name } = rules[0];

  const cvFilterScope = nockInstance
    .get(cvFilterDetailsPath)
    .query(true)
    .reply(200, cvFilterDetails);

  const cvFiltersScope = nockInstance
    .get(cvFiltersPath)
    .query(true)
    .reply(200, cvFilterFixtures);

  const cvFiltersRuleScope = nockInstance
    .delete(cvRemoveFilterRulePath)
    .reply(200, {});

  const packageGroupsScope = nockInstance
    .get(packageGroupsPath)
    .query(true)
    .reply(200, allPackageGroups);

  const cvRequestCallbackScope = nockInstance
    .get(cvRefreshCallbackPath)
    .query(true)
    .reply(200, cvFilterDetails);

  const { getAllByLabelText, getByText, queryByText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(name)).toBeInTheDocument();
    expect(getAllByLabelText('Kebab toggle')[2]).toHaveAttribute('aria-expanded', 'false');
  });
  fireEvent.click(getAllByLabelText('Kebab toggle')[2]);
  expect(getAllByLabelText('Kebab toggle')[2]).toHaveAttribute('aria-expanded', 'true');
  await patientlyWaitFor(() => expect(getByText('Remove')).toBeInTheDocument());
  fireEvent.click(getByText('Remove'));


  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvFiltersRuleScope);
  assertNockRequest(cvRequestCallbackScope);

  assertNockRequest(packageGroupsScope, done);
  act(done);
});

test('Can add a filter rule', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const { rules } = cvFilterDetails;
  const { name } = rules[0];

  const cvFilterScope = nockInstance
    .get(cvFilterDetailsPath)
    .query(true)
    .reply(200, cvFilterDetails);

  const cvFiltersScope = nockInstance
    .get(cvFiltersPath)
    .query(true)
    .reply(200, cvFilterFixtures);

  const cvFiltersRuleScope = nockInstance
    .post(cvAddFilterRulePath)
    .query(true)
    .reply(200, {});

  const packageGroupsScope = nockInstance
    .get(packageGroupsPath)
    .query(true)
    .reply(200, allPackageGroups);

  const cvRequestCallbackScope = nockInstance
    .get(cvRefreshCallbackPath)
    .query(true)
    .reply(200, cvFilterDetails);


  const { getAllByLabelText, getByText, queryByText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(name)).toBeInTheDocument();
    expect(getAllByLabelText('Kebab toggle')[1]).toHaveAttribute('aria-expanded', 'false');
  });
  fireEvent.click(getAllByLabelText('Kebab toggle')[1]);
  expect(getAllByLabelText('Kebab toggle')[1]).toHaveAttribute('aria-expanded', 'true');
  await patientlyWaitFor(() => expect(getByText('Add')).toBeInTheDocument());
  fireEvent.click(getByText('Add'));


  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvFiltersRuleScope);
  assertNockRequest(cvRequestCallbackScope);

  assertNockRequest(packageGroupsScope, done);
  act(done);
});

test('Can bulk remove filter rules', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const { rules } = cvFilterDetails;
  const { name } = rules[0];

  const cvFilterScope = nockInstance
    .get(cvFilterDetailsPath)
    .query(true)
    .reply(200, cvFilterDetails);

  const cvFiltersScope = nockInstance
    .get(cvFiltersPath)
    .query(true)
    .reply(200, cvFilterFixtures);

  const bulkDeleteParams = { rule_ids: [2, 1] };

  const cvFiltersRuleBulkDeleteScope = nockInstance
    .put(cvBulkRemoveFilterRulesPath, bulkDeleteParams)
    .reply(200, {});

  const packageGroupsScope = nockInstance
    .get(packageGroupsPath)
    .query(true)
    .reply(200, allPackageGroups);

  const cvRequestCallbackScope = nockInstance
    .get(cvRefreshCallbackPath)
    .query(true)
    .reply(200, cvFilterDetails);


  const { getByText, queryByText, getByLabelText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(name)).toBeInTheDocument();
    // "Select all rows"
    expect(getByLabelText('Select all rows')).toBeInTheDocument();
    expect(getByLabelText('bulk_actions')).toHaveAttribute('aria-expanded', 'false');
  });
  fireEvent.click(getByLabelText('Select all rows'));
  fireEvent.click(getByLabelText('bulk_actions'));
  expect(getByLabelText('bulk_actions')).toHaveAttribute('aria-expanded', 'true');
  expect(getByLabelText('bulk_remove')).toBeInTheDocument();
  fireEvent.click(getByLabelText('bulk_remove'));

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvFiltersRuleBulkDeleteScope);
  assertNockRequest(cvRequestCallbackScope);

  assertNockRequest(packageGroupsScope, done);
  act(done);
});

test('Can bulk add filter rules', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const { rules } = cvFilterDetails;
  const { name } = rules[0];

  const cvFilterScope = nockInstance
    .get(cvFilterDetailsPath)
    .query(true)
    .reply(200, cvFilterDetails);

  const cvFiltersScope = nockInstance
    .get(cvFiltersPath)
    .query(true)
    .reply(200, cvFilterFixtures);

  const bulkAddParams = { rules_params: [{ uuid: '/pulp/api/v3/content/rpm/packagegroups/ead4ed04-2569-4c2c-ab70-da5052f7dd33/' }] };

  const cvFiltersRuleBulkAddScope = nockInstance
    .put(cvBulkAddFilterRulesPath, bulkAddParams)
    .reply(200, {});

  const packageGroupsScope = nockInstance
    .get(packageGroupsPath)
    .query(true)
    .reply(200, allPackageGroups);

  const cvRequestCallbackScope = nockInstance
    .get(cvRefreshCallbackPath)
    .query(true)
    .reply(200, cvFilterDetails);


  const { getByText, queryByText, getByLabelText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(name)).toBeInTheDocument();
    expect(getByLabelText('Select all rows')).toBeInTheDocument();
    expect(getByLabelText('bulk_actions')).toHaveAttribute('aria-expanded', 'false');
  });
  fireEvent.click(getByLabelText('Select all rows'));
  expect(getByLabelText('add_filter_rule')).toBeInTheDocument();
  fireEvent.click(getByLabelText('add_filter_rule'));

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvFiltersRuleBulkAddScope);
  assertNockRequest(cvRequestCallbackScope);
  assertNockRequest(packageGroupsScope, done);
  act(done);
});

test('Can filter by added/not added rules', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const { rules } = cvFilterDetails;
  const { name } = rules[0];

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
    .times(3) // For first call (All), Added, and Not Added
    .reply(200, allPackageGroups);

  const {
    getByText, queryByText, getByTestId, getByLabelText,
  } = renderWithRedux(withCVRoute(<ContentViewFilterDetails
    cvId={1}
    details={details}
  />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(name)).toBeInTheDocument();
    expect(getByTestId('allAddedNotAdded')).toBeInTheDocument();
  });
  fireEvent.click(getByTestId('allAddedNotAdded')?.childNodes[0]?.childNodes[0]);
  await patientlyWaitFor(() => {
    expect(getByLabelText(ADDED)).toBeInTheDocument();
  });
  fireEvent.click(getByLabelText(ADDED));
  await patientlyWaitFor(() => {
    expect(getByText(name)).toBeInTheDocument();
    expect(getByTestId('allAddedNotAdded')).toBeInTheDocument();
  });
  fireEvent.click(getByTestId('allAddedNotAdded')?.childNodes[0]?.childNodes[0]);
  await patientlyWaitFor(() => {
    expect(getByLabelText(NOT_ADDED)).toBeInTheDocument();
  });
  fireEvent.click(getByLabelText(NOT_ADDED));

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(packageGroupsScope, done);
  act(done);
});

test('Can show affected repository tab on dropdown selection and add repos', async (done) => {
  const autocompleteScope = mockAutocomplete(
    nockInstance,
    autocompleteUrl,
    autocompleteQuery,
    [],
    2,
  );
  const autocompleteUrlRepo = '/repositories/auto_complete_search';
  const autocompleteQueryRepo = {
    organization_id: 1,
    search: '',
  };
  const autocompleteScopeRepo = mockAutocomplete(
    nockInstance,
    autocompleteUrlRepo,
    autocompleteQueryRepo,
    [],
    2,
  );

  const { rules } = cvFilterDetails;
  const { name } = rules[0];
  const { results } = cvAllRepos;
  const { name: repoName } = results[1];

  const cvFilterScope = nockInstance
    .get(cvFilterDetailsPath)
    .times(2)
    .query(true)
    .reply(200, cvFilterDetails);

  const cvFiltersScope = nockInstance
    .get(cvFiltersPath)
    .query(true)
    .reply(200, cvFilterFixtures);

  const cvAllReposScope = nockInstance
    .get(cvGetAllReposPath)
    .times(2)
    .query(true)
    .reply(200, cvAllRepos);

  const addRepoParams = { id: '1', repository_ids: [5, 9] };
  const bulkAddReposScope = nockInstance
    .put(cvFilterDetailsPath, addRepoParams)
    .reply(200, {});


  const packageGroupsScope = nockInstance
    .get(packageGroupsPath)
    .times(2)
    .query(true)
    .reply(200, allPackageGroups);


  const {
    getAllByLabelText, getByLabelText, getAllByText, getByText, queryByText,
  } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(name)).toBeInTheDocument();
    expect(getByText('Apply to all repositories in the CV')).toBeInTheDocument();
    expect(getAllByText('Apply to all repositories in the CV')[0].closest('button'))
      .toHaveAttribute('aria-expanded', 'false');
  });
  fireEvent.click(getByText('Apply to all repositories in the CV').closest('button'));
  await patientlyWaitFor(() => expect(getAllByText('Apply to all repositories in the CV')[0].closest('button'))
    .toHaveAttribute('aria-expanded', 'true'));
  fireEvent.click(getByText('Apply to subset of repositories').closest('button'));

  await patientlyWaitFor(() => {
    expect(getByText(repoName)).toBeInTheDocument();
  });
  expect(getByLabelText('add_repositories')).toHaveAttribute('aria-disabled', 'true');
  expect(getAllByLabelText('Select all rows')[1]).toBeInTheDocument();
  fireEvent.click(getAllByLabelText('Select all rows')[1]);
  expect(getByLabelText('add_repositories')).toHaveAttribute('aria-disabled', 'false');
  fireEvent.click(getByLabelText('add_repositories'));
  await patientlyWaitFor(() => {
    expect(getByLabelText('add_repositories')).toHaveAttribute('aria-disabled', 'true');
  });
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvAllReposScope);
  assertNockRequest(bulkAddReposScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvAllReposScope);
  assertNockRequest(autocompleteScope);
  assertNockRequest(autocompleteScopeRepo);
  assertNockRequest(packageGroupsScope, done);
  act(done);
});

test('Can show affected repository tab and remove affected repos', async (done) => {
  const autocompleteScope = mockAutocomplete(
    nockInstance,
    autocompleteUrl,
    autocompleteQuery,
    [],
    2,
  );
  const autocompleteUrlRepo = '/repositories/auto_complete_search';
  const autocompleteQueryRepo = {
    organization_id: 1,
    search: '',
  };
  const autocompleteScopeRepo = mockAutocomplete(
    nockInstance,
    autocompleteUrlRepo,
    autocompleteQueryRepo,
    [],
    2,
  );
  const { rules } = cvFilterDetailsAffectedRepos;
  const { name } = rules[0];
  const { results } = cvAllRepos;
  const { name: repoName } = results[1];

  const cvFilterScope = nockInstance
    .get(cvFilterDetailsPath)
    .times(2)
    .query(true)
    .reply(200, cvFilterDetailsAffectedRepos);

  const cvFiltersScope = nockInstance
    .get(cvFiltersPath)
    .query(true)
    .reply(200, cvFilterFixtures);

  const cvAllReposScope = nockInstance
    .get(cvGetAllReposPath)
    .times(2)
    .query(true)
    .reply(200, cvAllRepos);

  const removeRepoParams = { id: '1', repository_ids: [] };
  const bulkRemoveReposScope = nockInstance
    .put(cvFilterDetailsPath, removeRepoParams)
    .reply(200, {});


  const packageGroupsScope = nockInstance
    .get(packageGroupsPath)
    .times(2)
    .query(true)
    .reply(200, allPackageGroups);

  const {
    getAllByLabelText, getByLabelText, getByText, queryByText,
  } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(name)).toBeInTheDocument();
    expect(getByText('Apply to subset of repositories')).toBeInTheDocument();
  });
  fireEvent.click(getByText('Affected repositories').closest('button'));
  await patientlyWaitFor(() => {
    expect(getByText(repoName)).toBeInTheDocument();
  });
  expect(getByLabelText('add_repositories')).toHaveAttribute('aria-disabled', 'true');
  expect(getAllByLabelText('Select all rows')[1]).toBeInTheDocument();
  fireEvent.click(getAllByLabelText('Select all rows')[1]);
  expect(getAllByLabelText('bulk_actions')[1]).toHaveAttribute('aria-expanded', 'false');
  fireEvent.click(getAllByLabelText('bulk_actions')[1]);
  expect(getByLabelText('bulk_remove')).toHaveAttribute('aria-disabled', 'false');
  fireEvent.click(getByLabelText('bulk_remove'));

  assertNockRequest(autocompleteScope);
  assertNockRequest(autocompleteScopeRepo);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvAllReposScope);
  assertNockRequest(bulkRemoveReposScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvAllReposScope);
  assertNockRequest(packageGroupsScope);
  done();
});
