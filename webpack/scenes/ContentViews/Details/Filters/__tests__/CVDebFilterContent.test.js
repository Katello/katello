import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { screen, within } from '@testing-library/react';
import { Route } from 'react-router-dom';

import ContentViewFilterDetails from '../ContentViewFilterDetails';
import { cvFilterDetailsKey } from '../../../ContentViewsConstants';
import { nockInstance, assertNockRequest, mockAutocomplete } from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';

import cvDebFilterDetails from './cvDebFilterDetail.fixtures.json';
import cvDebFilterRules from './cvDebFilterRules.fixtures.json';
import cvFilterFixtures from './contentViewFilters.fixtures.json';
import details from '../../../__tests__/mockDetails.fixtures.json';
import emptyDebFilterRules from './emptyCVDebFilterRules.fixtures.json';

const cvFiltersPath = api.getApiUrl('/content_view_filters');
const cvFilterDetailsPath = api.getApiUrl('/content_view_filters/42');
const cvDebFilterRulesPath = api.getApiUrl('/content_view_filters/42/rules');
// const cvDebFilterRulesNew = api.getApiUrl('/content_view_filters/42/rules');
const cvDebFilterRulesDel = api.getApiUrl('/content_view_filters/42/rules/99');
const cvDebFilterRulesEdit = api.getApiUrl('/content_view_filters/42/rules/100');

const acRulesUrl = '/content_view_filters/42/rules/auto_complete_search';
const acNameUrl = '/debs/auto_complete_name';
const acArchUrl = '/debs/auto_complete_arch';

const acRulesQuery = { organization_id: 1, search: '' };
const acBlankTermQuery = { organization_id: 1, term: '' };

const renderOptions = {
  apiNamespace: cvFilterDetailsKey(1, 42),
  routerParams: {
    initialEntries: [{ pathname: '/content_views/1#/filters/42', hash: '#/filters' }],
    initialIndex: 1,
  },
};

const withCVRoute = c => (
  <Route path="/content_views/:id([0-9]+)#/filters/:filterId([0-9]+)">{c}</Route>
);

test('Can show filter details on Deb rules', async () => {
  const { name: filterName } = cvDebFilterDetails;

  const cvFilterDetailsScope = nockInstance
    .get(cvFilterDetailsPath)
    .query(true)
    .reply(200, cvDebFilterDetails);
  const cvFiltersScope = nockInstance
    .get(cvFiltersPath).query(true).reply(200, cvFilterFixtures)
    .persist();
  const cvDebRulesScope = nockInstance
    .get(cvDebFilterRulesPath).query(true)
    .reply(200, cvDebFilterRules);

  const acRulesScope = mockAutocomplete(nockInstance, acRulesUrl, acRulesQuery);

  const { getByText, queryByText } = renderWithRedux(
    withCVRoute(<ContentViewFilterDetails cvId={1} details={details} />),
    renderOptions,
  );

  expect(queryByText(filterName)).toBeNull();
  await patientlyWaitFor(() => expect(getByText(filterName)).toBeInTheDocument());

  assertNockRequest(acRulesScope);
  assertNockRequest(cvFilterDetailsScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvDebRulesScope);
});

test('Can search for Deb rules in filter details', async () => {
  const lastRule = cvDebFilterRules.results[1];
  const rulesSearchQuery = {
    organization_id: 1,
    search: `name = ${lastRule.name}`,
  };

  const rulesSearchResults = [
    {
      completed: `name = ${lastRule.name}`,
      part: 'and',
      label: `name = ${lastRule.name} and`,
      category: 'Operators',
    },
    {
      completed: `name = ${lastRule.name}`,
      part: 'or',
      label: `name = ${lastRule.name} or`,
      category: 'Operators',
    },
  ];

  const cvFilterDetailsScope = nockInstance
    .get(cvFilterDetailsPath).query(true)
    .reply(200, cvDebFilterDetails);

  nockInstance.get(cvFiltersPath).query(true).reply(200, cvFilterFixtures);

  const cvDebRulesScope = nockInstance
    .get(cvDebFilterRulesPath).query(true)
    .reply(200, cvDebFilterRules);

  const ruleSearchScope = nockInstance
    .get(cvDebFilterRulesPath).query(rulesSearchQuery)
    .reply(200, { results: [lastRule] });

  const acRulesScope = mockAutocomplete(nockInstance, acRulesUrl, acRulesQuery);
  const acRulesSearch = mockAutocomplete(
    nockInstance,
    acRulesUrl,
    rulesSearchQuery,
    rulesSearchResults,
  );

  const { getByText, getByLabelText } = renderWithRedux(
    withCVRoute(<ContentViewFilterDetails cvId={1} details={details} />),
    renderOptions,
  );

  await patientlyWaitFor(() => expect(getByText(lastRule.name)).toBeInTheDocument());

  fireEvent.change(getByLabelText('Search input'), {
    target: { value: `name = ${lastRule.name}` },
  });
  fireEvent.keyDown(getByLabelText('Search input'), {
    key: 'Enter',
    code: 'Enter',
    charCode: 13,
  });

  await patientlyWaitFor(() => {
    expect(getByText(lastRule.name)).toBeInTheDocument();
  });

  assertNockRequest(acRulesScope);
  assertNockRequest(acRulesSearch);
  assertNockRequest(ruleSearchScope);
  assertNockRequest(cvFilterDetailsScope);
  assertNockRequest(cvDebRulesScope);
});

test('Remove deb filter rule in a self-closing modal', async () => {
  const { name: filterName } = cvDebFilterDetails;

  const acRulesScope = mockAutocomplete(nockInstance, acRulesUrl, acRulesQuery);
  const acNameScope = mockAutocomplete(nockInstance, acNameUrl, acBlankTermQuery).persist();
  const acArchScope = mockAutocomplete(nockInstance, acArchUrl, acBlankTermQuery).persist();

  const cvFiltersScope = nockInstance
    .get(cvFiltersPath).query(true).reply(200, cvFilterFixtures);
  const cvDetailsScope = nockInstance
    .get(cvFilterDetailsPath).query(true).reply(200, cvDebFilterDetails);
  const cvDebRulesScope = nockInstance
    .get(cvDebFilterRulesPath).times(2).query(true).reply(200, cvDebFilterRules);

  const removeScope = nockInstance
    .delete(cvDebFilterRulesDel)
    .reply(201, {});

  const { getByText, queryByText, getAllByLabelText } =
    renderWithRedux(
      withCVRoute(<ContentViewFilterDetails cvId={1} details={details} />),
      renderOptions,
    );

  expect(queryByText(filterName)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getByText(filterName)).toBeInTheDocument();
    expect(getAllByLabelText('Kebab toggle')[0]).toBeInTheDocument();
  });

  getAllByLabelText('Kebab toggle')[0].click();
  await patientlyWaitFor(() => expect(getByText('Remove')).toBeInTheDocument());
  getByText('Remove').click();

  await patientlyWaitFor(() => {
    expect(getByText(filterName)).toBeInTheDocument();
    expect(getAllByLabelText('Kebab toggle')[1]).toBeInTheDocument();
  });

  assertNockRequest(acRulesScope);
  assertNockRequest(acNameScope);
  assertNockRequest(acArchScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvDetailsScope);
  assertNockRequest(cvDebRulesScope);
  assertNockRequest(removeScope);
});

test('Edit deb filter rule in a self-closing modal', async () => {
  const { name: filterName } = cvDebFilterDetails;

  const acRulesScope = mockAutocomplete(nockInstance, acRulesUrl, true, undefined, 2);
  const acNameScope = mockAutocomplete(nockInstance, acNameUrl, true, undefined, 2).persist();
  const acArchScope = mockAutocomplete(nockInstance, acArchUrl, true, undefined, 2).persist();

  nockInstance.get(cvFiltersPath).times(2).query(true).reply(200, cvFilterFixtures);
  nockInstance.get(cvFilterDetailsPath).times(2).query(true).reply(200, cvDebFilterDetails);
  nockInstance.persist().get(cvDebFilterRulesPath).query(true).reply(200, cvDebFilterRules);

  const editScope = nockInstance.put(cvDebFilterRulesEdit).query(true).reply(201, {});

  const { getByText, getByLabelText, queryByText } =
    renderWithRedux(
      withCVRoute(<ContentViewFilterDetails cvId={1} details={details} />),
      renderOptions,
    );

  await patientlyWaitFor(() => expect(getByText(filterName)).toBeInTheDocument());
  const table = await screen.findByLabelText('Content View Table');
  const unoRow = within(table).getByText('uno').closest('tr');
  const kebabBtn = within(unoRow).getByLabelText('Kebab toggle');
  fireEvent.click(kebabBtn);

  await patientlyWaitFor(() => expect(getByText('Edit')).toBeInTheDocument());
  fireEvent.click(getByText('Edit'));

  await patientlyWaitFor(() => expect(getByText('Edit DEB rule')).toBeInTheDocument());
  fireEvent.submit(getByLabelText('add_deb_package_filter_rule'));

  await patientlyWaitFor(() => {
    expect(queryByText('Edit DEB rule')).not.toBeInTheDocument();
    expect(getByText(filterName)).toBeInTheDocument();
  });

  assertNockRequest(acRulesScope);
  assertNockRequest(acNameScope);
  assertNockRequest(acArchScope);
  assertNockRequest(editScope);
});

test('Shows call-to-action when there are no DEB filters', async () => {
  const acRulesScope = mockAutocomplete(nockInstance, acRulesUrl);
  const acNameScope = mockAutocomplete(nockInstance, acNameUrl);
  const acArchScope = mockAutocomplete(nockInstance, acArchUrl);

  nockInstance.get(cvFiltersPath).query(true).reply(200, cvFilterFixtures);
  const cvFilterDetailsScope = nockInstance
    .get(cvFilterDetailsPath).query(true).reply(200, cvDebFilterDetails);
  const cvDebRulesScope = nockInstance
    .get(cvDebFilterRulesPath).query(true).reply(200, emptyDebFilterRules);

  const { queryByLabelText, queryByText, getAllByLabelText } =
    renderWithRedux(
      withCVRoute(<ContentViewFilterDetails cvId={1} details={details} />),
      renderOptions,
    );

  await patientlyWaitFor(() => expect(queryByLabelText('create_deb_rule')).toBeInTheDocument());
  fireEvent.click(queryByLabelText('create_deb_rule'));

  await patientlyWaitFor(() => {
    expect(getAllByLabelText('Search input')[0]).toBeInTheDocument();
    expect(queryByText('Cancel')).toBeInTheDocument();
  });

  fireEvent.click(queryByText('Cancel'));
  await patientlyWaitFor(() =>
    expect(queryByLabelText('add-edit-package-modal-cancel')).not.toBeInTheDocument());

  assertNockRequest(acRulesScope);
  assertNockRequest(acNameScope);
  assertNockRequest(acArchScope);
  assertNockRequest(cvFilterDetailsScope);
  assertNockRequest(cvDebRulesScope);
});
