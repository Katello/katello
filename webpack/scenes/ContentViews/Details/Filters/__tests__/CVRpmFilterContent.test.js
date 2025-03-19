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
import cvFilterDetails from './cvPackageFilterDetail.fixtures.json';
import cvPackageFilterRules from './cvPackageFilterRules.fixtures.json';
import cvFilterFixtures from './contentViewFilters.fixtures.json';
import details from '../../../__tests__/mockDetails.fixtures.json';
// import emptyContentViewFiltersData from './emptyContentViewFilters.fixtures.json';
import emptyCVPackageFilterRules from './emptyCVPackageFilterRules.fixtures.json';

const cvFiltersPath = api.getApiUrl('/content_view_filters');
const cvFilterDetailsPath = api.getApiUrl('/content_view_filters/2');
const cvFilterEditDeletePath = api.getApiUrl('/content_view_filters/2/rules/2');
const cvPackageFilterRulesPath = api.getApiUrl('/content_view_filters/2/rules');
const cvPackageFilterRuleCreatePath = api.getApiUrl('/content_view_filters/2/rules');
const autocompleteUrl = '/content_view_filters/2/rules/auto_complete_search';
const autocompleteNameUrl = '/packages/auto_complete_name';
const autocompleteArchUrl = '/packages/auto_complete_arch';
const renderOptions = {
  apiNamespace: cvFilterDetailsKey(1, 2),
  routerParams: {
    initialEntries: [{ pathname: '/content_views/1#/filters/2', hash: '#/filters' }],
    initialIndex: 1,
  },
};
const autocompleteQuery = {
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
  const cvPackageFilterRulesScope = nockInstance
    .get(cvPackageFilterRulesPath)
    .query(true)
    .reply(200, cvPackageFilterRules);
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
  assertNockRequest(cvPackageFilterRulesScope);
  act(done);
});

test('Can search for package rules in package filter details', async (done) => {
  const firstPackageRule = cvPackageFilterRules.results[0];
  const lastPackageRule = cvPackageFilterRules.results[1];
  const { name: cvFilterName } = cvFilterDetails;
  const { name: firstPackageRuleName } = firstPackageRule;
  const { name: lastPackageRuleName } = lastPackageRule;
  const searchQueryMatcher = {
    organization_id: 1,
    search: `name = ${lastPackageRuleName}`,
  };
  const searchResults = [
    {
      completed: `name = ${lastPackageRuleName}`,
      part: 'and',
      label: `name = ${lastPackageRuleName} and`,
      category: 'Operators',
    },
    {
      completed: `name = ${lastPackageRuleName}`,
      part: 'or',
      label: `name = ${lastPackageRuleName} or`,
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
  const cvPackageFilterRulesScope = nockInstance
    .get(cvPackageFilterRulesPath)
    .query(true)
    .reply(200, cvPackageFilterRules);
  const packageRuleSearchScope = nockInstance
    .get(cvPackageFilterRulesPath)
    .query(searchQueryMatcher)
    .reply(200, { results: [lastPackageRule] });

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
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
    expect(getByText(firstPackageRuleName)).toBeInTheDocument();
  });

  // Search and only searched result shows
  getByLabelText('Search input').focus();
  fireEvent.change(getByLabelText('Search input'), { target: { value: `name = ${lastPackageRuleName}` } });
  await patientlyWaitFor(() => {
    expect(getByText(`name = ${lastPackageRuleName} and`)).toBeInTheDocument();
    expect(queryByText(`name = ${firstPackageRuleName} and`)).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvPackageFilterRulesScope);
  assertNockRequest(withSearchScope);
  assertNockRequest(packageRuleSearchScope);
  act(done);
});

test('Can add package rules to filter in a self-closing modal', async (done) => {
  const { name: cvFilterName } = cvFilterDetails;
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, true, undefined, 2);
  const autocompleteNameScope = mockAutocomplete(
    nockInstance, autocompleteNameUrl, true,
    undefined, 2,
  );
  const autocompleteArchScope = mockAutocomplete(
    nockInstance, autocompleteArchUrl, true,
    undefined, 2,
  );

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

  const {
    getByText, queryByText, getByLabelText, getAllByLabelText,
  } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(cvFilterName)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getByText(cvFilterName)).toBeInTheDocument();
    expect(getByLabelText('add_rpm_rule')).toBeInTheDocument();
  });
  getByLabelText('add_rpm_rule').click();
  await patientlyWaitFor(() => {
    expect(getAllByLabelText('Search input')[0]).toBeInTheDocument();
    expect(getAllByLabelText('Search input')[1]).toBeInTheDocument();
    expect(getByLabelText('add_package_filter_rule')).toBeInTheDocument();
  });
  const nameSearchInput = getAllByLabelText('Search input')[1];
  const archSearchInput = getAllByLabelText('Search input')[2];
  nameSearchInput.focus();
  fireEvent.change(nameSearchInput, { target: { value: 'elephant' } });
  archSearchInput.focus();
  fireEvent.change(archSearchInput, { target: { value: 'noarch' } });
  fireEvent.submit(getByLabelText('add_package_filter_rule'));

  await patientlyWaitFor(() => {
    expect(queryByText('Add rule')).not.toBeInTheDocument();
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(autocompleteNameScope);
  assertNockRequest(autocompleteArchScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvFilterDetailsScope);
  assertNockRequest(cvPackageFilterRulesScope);
  assertNockRequest(createscope);
  assertNockRequest(cvPackageFilterRulesScope);
  act(done);
});

test('Remove rpm filter rule in a self-closing modal', async (done) => {
  const { name: cvFilterName } = cvFilterDetails;
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

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

  const removeScope = nockInstance
    .delete(cvFilterEditDeletePath)
    .reply(201, {});


  const { getByText, queryByText, getAllByLabelText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(cvFilterName)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getByText(cvFilterName)).toBeInTheDocument();
    expect(getAllByLabelText('Kebab toggle')[0]).toBeInTheDocument();
  });
  getAllByLabelText('Kebab toggle')[0].click();
  await patientlyWaitFor(() => {
    expect(getByText('Remove')).toBeInTheDocument();
  });

  getByText('Remove').click();
  await patientlyWaitFor(() => {
    expect(getByText(cvFilterName)).toBeInTheDocument();
    expect(getAllByLabelText('Kebab toggle')[1]).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvFilterDetailsScope);
  assertNockRequest(cvPackageFilterRulesScope);
  assertNockRequest(removeScope);
  assertNockRequest(cvPackageFilterRulesScope);
  act(done);
});

test('Edit rpm filter rule in a self-closing modal', async (done) => {
  const { name: cvFilterName } = cvFilterDetails;
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, true, undefined, 2);
  const autocompleteNameScope = mockAutocomplete(
    nockInstance, autocompleteNameUrl, true,
    undefined, 2,
  );
  const autocompleteArchScope = mockAutocomplete(
    nockInstance, autocompleteArchUrl, true,
    undefined, 2,
  );
  const cvFiltersScope = nockInstance
    .get(cvFiltersPath)
    .times(2)
    .query(true)
    .reply(200, cvFilterFixtures);
  const cvFilterDetailsScope = nockInstance
    .get(cvFilterDetailsPath)
    .times(2)
    .query(true)
    .reply(200, cvFilterDetails);
  const cvPackageFilterRulesScope = nockInstance
    .persist()
    .get(cvPackageFilterRulesPath)
    .query(true)
    .reply(200, cvPackageFilterRules);

  const editScope = nockInstance
    .put(cvFilterEditDeletePath)
    .query(true)
    .reply(201, {});

  const {
    getByText, queryByText, getAllByLabelText, getByLabelText,
  } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(cvFilterName)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getByText(cvFilterName)).toBeInTheDocument();
    expect(getAllByLabelText('Kebab toggle')[0]).toBeInTheDocument();
  });
  fireEvent.click(getAllByLabelText('Kebab toggle')[0]);
  await patientlyWaitFor(() => {
    expect(getByText('Edit')).toBeInTheDocument();
  });

  fireEvent.click(getByText('Edit'));

  await patientlyWaitFor(() => {
    expect(getByText('Edit RPM rule')).toBeInTheDocument();
  });
  fireEvent.submit(getByLabelText('add_package_filter_rule'));
  await patientlyWaitFor(() => {
    expect(queryByText('Edit RPM rule')).not.toBeInTheDocument();
    expect(getByText(cvFilterName)).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(autocompleteNameScope);
  assertNockRequest(autocompleteArchScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvFilterDetailsScope);
  assertNockRequest(cvPackageFilterRulesScope);
  assertNockRequest(editScope);
  act(done);
});

test('Shows call-to-action when there are no RPM filters', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const autocompleteNameScope = mockAutocomplete(nockInstance, autocompleteNameUrl);
  const autocompleteArchScope = mockAutocomplete(nockInstance, autocompleteArchUrl);
  const cvFilterDetailScope = nockInstance
    .get(cvFilterDetailsPath)
    .query(true)
    .reply(200, cvFilterDetails);
  const cvFiltersScope = nockInstance
    .get(cvFiltersPath)
    .query(true)
    .reply(200, cvFilterFixtures);
  const cvPackageFilterRulesScope = nockInstance
    .get(cvPackageFilterRulesPath)
    .times(1)
    .query(true)
    .reply(200, emptyCVPackageFilterRules);
  const {
    queryByLabelText, queryByText, getAllByLabelText,
  } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);
  expect(queryByLabelText('add_rpm_rule_empty_state')).not.toBeInTheDocument();
  await patientlyWaitFor(() => expect(queryByLabelText('add_rpm_rule_empty_state')).toBeInTheDocument());
  fireEvent.click(queryByLabelText('add_rpm_rule_empty_state'));

  await patientlyWaitFor(() => {
    expect(getAllByLabelText('Search input')[0]).toBeInTheDocument();
    expect(queryByText('Cancel')).toBeInTheDocument();
  });
  fireEvent.click(queryByText('Cancel'));
  await patientlyWaitFor(() => {
    expect(queryByLabelText('add-edit-package-modal-cancel')).not.toBeInTheDocument();
  });
  assertNockRequest(autocompleteNameScope);
  assertNockRequest(autocompleteArchScope);
  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvFilterDetailScope);
  assertNockRequest(cvPackageFilterRulesScope, done);
  act(done);
});
