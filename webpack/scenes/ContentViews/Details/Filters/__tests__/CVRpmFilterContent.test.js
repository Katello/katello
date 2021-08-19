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

const cvFilterDetails = require('./cvPackageFilterDetail.fixtures.json');
const cvPackageFilterRules = require('./cvPackageFilterRules.fixtures.json');
const cvFilterFixtures = require('./contentViewFilters.fixtures.json');

const cvFiltersPath = api.getApiUrl('/content_view_filters');
const cvFilterDetailsPath = api.getApiUrl('/content_view_filters/2');
const cvPackageFilterRulesPath = api.getApiUrl('/content_view_filters/2/rules');
const cvPackageFilterRuleCreatePath = api.getApiUrl('/content_view_filters/2/rules');
const autocompleteUrl = '/content_view_filters/2/rules/auto_complete_search';
const renderOptions = {
  apiNamespace: cvFilterDetailsKey(1, 2),
  routerParams: {
    initialEntries: [{ hash: '#filters?subContentId=2', pathname: '/labs/content_views/1' }],
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
  const cvPackageFilterRulesScope = nockInstance
    .get(cvPackageFilterRulesPath)
    .query(true)
    .reply(200, cvPackageFilterRules);
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { getByText, queryByText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails cvId={1} />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(cvFilterName)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getByText(cvFilterName)).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvPackageFilterRulesScope, done);
});

test('Can search for package rules in package filter details', async (done) => {
  const firstPackageRule = cvPackageFilterRules.results[0];
  const lastPackageRule = cvPackageFilterRules.results[1];
  const { name: cvFilterName } = cvFilterDetails;
  const { name: firstPackageRuleName } = firstPackageRule;
  const { name: lastPackageRuleName } = lastPackageRule;
  const searchQueryMatcher = actualParams => actualParams?.search?.includes(lastPackageRuleName);

  const cvFilterScope = nockInstance
    .get(cvFilterDetailsPath)
    .query(true)
    .reply(200, cvFilterDetails);
  const cvFiltersScope = nockInstance
    .get(cvFiltersPath)
    .query(true)
    .reply(200, cvFilterFixtures);
  const cvPackageFilterRulesScope = nockInstance
    .get(cvPackageFilterRulesPath)
    .query(true)
    .reply(200, cvPackageFilterRules);
  const packageRuleSearchScope = nockInstance
    .get(cvPackageFilterRulesPath)
    .query(searchQueryMatcher)
    .reply(200, { results: [lastPackageRule] });

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const withSearchScope = mockAutocomplete(nockInstance, autocompleteUrl, searchQueryMatcher);
  const { getByText, queryByText, getByLabelText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails cvId={1} />), renderOptions);

  // Basic results showing
  await patientlyWaitFor(() => {
    expect(getByText(cvFilterName)).toBeInTheDocument();
    expect(getByText(firstPackageRuleName)).toBeInTheDocument();
  });

  // Search and only searched result shows
  fireEvent.change(getByLabelText(/text input for search/i), { target: { value: lastPackageRuleName } });
  getByLabelText(/search button/i).click();
  await patientlyWaitFor(() => {
    expect(getByText(lastPackageRuleName)).toBeInTheDocument();
    expect(queryByText(firstPackageRuleName)).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvPackageFilterRulesScope);
  assertNockRequest(withSearchScope);
  assertNockRequest(packageRuleSearchScope, done);
});

test('Can add package rules to filter in a self-closing modal', async (done) => {
  const { name: cvFilterName } = cvFilterDetails;
  const cvFiltersScope = nockInstance
    .get(cvFiltersPath)
    .query(true)
    .reply(200, cvFilterFixtures);
  const cvFilterDetailsScope = nockInstance
    .get(cvFilterDetailsPath)
    .query(true)
    .reply(200, cvFilterDetails);
  const cvPackageFilterRulesScope = nockInstance
    .get(cvPackageFilterRulesPath)
    .times(2) // One on initial page load and one after rule create
    .query(true)
    .reply(200, cvPackageFilterRules);

  const newFilterRuleDetails = {
    architecture: 'noarch',
    name: 'elephant',
  };
  const createdFilterDetails = {
    architecture: 'noarch',
    content_view_filter_id: 1,
    created_at: '2021-08-06 06:12:10 -0400',
    id: 3,
    name: 'elephant',
    updated_at: '2021-08-06 06:12:10 -0400',
  };

  const createscope = nockInstance
    .post(cvPackageFilterRuleCreatePath, newFilterRuleDetails)
    .reply(201, createdFilterDetails);

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { getByText, queryByText, getByLabelText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails cvId={1} />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(cvFilterName)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getByText(cvFilterName)).toBeInTheDocument();
    expect(getByLabelText('create_rpm_rule')).toBeInTheDocument();
  });
  getByLabelText('create_rpm_rule').click();
  await patientlyWaitFor(() => {
    expect(getByText('RPM name')).toBeInTheDocument();
    expect(getByText('Architecture')).toBeInTheDocument();
    expect(getByLabelText('create_package_filter_rule')).toBeInTheDocument();
  });

  fireEvent.change(getByLabelText('input_name'), { target: { value: 'elephant' } });
  fireEvent.change(getByLabelText('input_architecture'), { target: { value: 'noarch' } });
  getByLabelText('create_package_filter_rule').click();

  await patientlyWaitFor(() => {
    expect(queryByText('Create rule')).not.toBeInTheDocument();
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvFilterDetailsScope);
  assertNockRequest(cvPackageFilterRulesScope);
  assertNockRequest(createscope);
  assertNockRequest(cvPackageFilterRulesScope, done);
});
