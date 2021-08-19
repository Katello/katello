import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { Route } from 'react-router-dom';

import ContentViewFilterDetails from '../ContentViewFilterDetails';
import { cvFilterDetailsKey } from '../../../ContentViewsConstants';
import nock, {
  nockInstance,
  assertNockRequest,
  mockAutocomplete,
  mockSetting,
} from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';

const allPackageGroups = require('./allFilterPackageGroups.fixtures.json');
const cvFilterDetails = require('./contentViewFilterDetail.fixtures.json');
const cvFilterFixtures = require('./contentViewFilters.fixtures.json');

const cvRefreshCallbackPath = api.getApiUrl('/content_views/2');
const cvFiltersPath = api.getApiUrl('/content_view_filters');

const cvAddFilterRulePath = api.getApiUrl('/content_view_filters/1/rules');
const cvRemoveFilterRulePath = api.getApiUrl('/content_view_filters/1/rules/1');
const cvFilterDetailsPath = api.getApiUrl('/content_view_filters/1');
const cvBulkRemoveFilterRulesPath = api.getApiUrl('/content_view_filters/1/remove_filter_rules');
const cvBulkAddFilterRulesPath = api.getApiUrl('/content_view_filters/1/add_filter_rules');

const packageGroupsPath = api.getApiUrl('/package_groups');
const autocompleteUrl = '/package_groups/auto_complete_search';
const renderOptions = {
  apiNamespace: cvFilterDetailsKey(1, 1),
  routerParams: {
    initialEntries: [{ hash: '#filters?subContentId=1', pathname: '/labs/content_views/2' }],
    initialIndex: 1,
  },
};

const withCVRoute = component => <Route path="/labs/content_views/:id">{component}</Route>;

let searchDelayScope;
let autoSearchScope;
beforeEach(() => {
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
  // Autosearch can cause some asynchronous issues with the typing timeout, using basic search
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', false);
});

afterEach(() => {
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
  nock.cleanAll();
});

test('Can enable and disable add filter button', async (done) => {
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
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { getByText, queryByText, getByLabelText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails cvId={1} />), renderOptions);

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
});


test('Can remove a filter rule', async (done) => {
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

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { getAllByLabelText, getByText, queryByText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails cvId={1} />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(name)).toBeInTheDocument();
    expect(getAllByLabelText('Actions')[1]).toHaveAttribute('aria-expanded', 'false');
  });
  fireEvent.click(getAllByLabelText('Actions')[1]);
  expect(getAllByLabelText('Actions')[1]).toHaveAttribute('aria-expanded', 'true');
  await patientlyWaitFor(() => expect(getByText('Remove')).toBeInTheDocument());
  fireEvent.click(getByText('Remove'));


  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvFiltersRuleScope);
  assertNockRequest(cvRequestCallbackScope);

  assertNockRequest(packageGroupsScope, done);
});

test('Can add a filter rule', async (done) => {
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

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { getAllByLabelText, getByText, queryByText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails cvId={1} />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(name)).toBeInTheDocument();
    expect(getAllByLabelText('Actions')[2]).toHaveAttribute('aria-expanded', 'false');
  });
  fireEvent.click(getAllByLabelText('Actions')[2]);
  expect(getAllByLabelText('Actions')[2]).toHaveAttribute('aria-expanded', 'true');
  await patientlyWaitFor(() => expect(getByText('Add')).toBeInTheDocument());
  fireEvent.click(getByText('Add'));


  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvFiltersRuleScope);
  assertNockRequest(cvRequestCallbackScope);

  assertNockRequest(packageGroupsScope, done);
});

test('Can bulk remove filter rules', async (done) => {
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

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { getByText, queryByText, getByLabelText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails cvId={1} />), renderOptions);

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
});

test('Can bulk add filter rules', async (done) => {
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

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { getByText, queryByText, getByLabelText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails cvId={1} />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(name)).toBeInTheDocument();
    expect(getByLabelText('Select all rows')).toBeInTheDocument();
    expect(getByLabelText('bulk_actions')).toHaveAttribute('aria-expanded', 'false');
  });
  fireEvent.click(getByLabelText('Select all rows'));
  fireEvent.click(getByLabelText('bulk_actions'));
  expect(getByLabelText('bulk_actions')).toHaveAttribute('aria-expanded', 'true');
  expect(getByLabelText('bulk_add')).toBeInTheDocument();
  fireEvent.click(getByLabelText('bulk_add'));

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvFiltersRuleBulkAddScope);
  assertNockRequest(cvRequestCallbackScope);

  assertNockRequest(packageGroupsScope, done);
});
