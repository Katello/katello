import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { Route } from 'react-router-dom';

import ContentViewFilterDetails from '../ContentViewFilterDetails';
import { cvFilterDetailsKey } from '../../../ContentViewsConstants';
import {
  nockInstance,
  assertNockRequest,
  mockAutocomplete,
  mockSetting,
} from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import allErrata from './allFilterErrata.fixtures.json';
import cvFilterDetails from './cvErratumFilterDetails.fixtures.json';
import cvFilterFixtures from './contentViewFilters.fixtures.json';
import details from '../../../__tests__/mockDetails.fixtures.json';

const cvFiltersPath = api.getApiUrl('/content_view_filters');
const cvRefreshCallbackPath = api.getApiUrl('/content_views/1');

const cvFilterDetailsPath = api.getApiUrl('/content_view_filters/6');
const cvAddFilterRulePath = api.getApiUrl('/content_view_filters/6/rules');
const cvRemoveFilterRulePath = api.getApiUrl('/content_view_filters/6/rules/4');
const cvBulkRemoveFilterRulesPath = api.getApiUrl('/content_view_filters/6/remove_filter_rules');
const cvBulkAddFilterRulesPath = api.getApiUrl('/content_view_filters/6/add_filter_rules');

const errataPath = api.getApiUrl('/errata');
const autocompleteUrl = '/errata/auto_complete_search';
const renderOptions = {
  apiNamespace: cvFilterDetailsKey(1, 6),
  routerParams: {
    initialEntries: [{ pathname: '/content_views/1#/filters/6' }],
    initialIndex: 1,
  },
};

const withCVRoute = component => <Route path="/content_views/:id([0-9]+)#/filters/:filterId([0-9]+)">{component}</Route>;

let searchDelayScope;
let autoSearchScope;
beforeEach(() => {
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 0);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing');
});

afterEach(() => {
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
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
  const errataScope = nockInstance
    .get(errataPath)
    .query(true)
    .reply(200, allErrata);
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

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
  assertNockRequest(errataScope, done);
});

test('Can add a filter rule', async (done) => {
  const { rules } = cvFilterDetails;
  const errataId = rules[0].errata_id;

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

  const errataScope = nockInstance
    .get(errataPath)
    .query(true)
    .reply(200, allErrata);

  const cvRequestCallbackScope = nockInstance
    .get(cvRefreshCallbackPath)
    .query(true)
    .reply(200, cvFilterDetails);

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { getAllByLabelText, getByText, queryByText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(errataId)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(errataId)).toBeInTheDocument();
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

  assertNockRequest(errataScope, done);
});

test('Can remove a filter rule', async (done) => {
  const { rules } = cvFilterDetails;
  const errataId = rules[0].errata_id; // 'RHEA-2012:0055'

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

  const errataScope = nockInstance
    .get(errataPath)
    .query(true)
    .reply(200, allErrata);

  const cvRequestCallbackScope = nockInstance
    .get(cvRefreshCallbackPath)
    .query(true)
    .reply(200, cvFilterDetails);

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { getAllByLabelText, getByText, queryByText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(errataId)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(errataId)).toBeInTheDocument();
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

  assertNockRequest(errataScope, done);
});

test('Can bulk remove filter rules', async (done) => {
  const { rules } = cvFilterDetails;
  const errataId = rules[0].errata_id;

  const cvFilterScope = nockInstance
    .get(cvFilterDetailsPath)
    .query(true)
    .reply(200, cvFilterDetails);

  const cvFiltersScope = nockInstance
    .get(cvFiltersPath)
    .query(true)
    .reply(200, cvFilterFixtures);

  const bulkDeleteParams = { rule_ids: [1, 4] };

  const cvFiltersRuleBulkDeleteScope = nockInstance
    .put(cvBulkRemoveFilterRulesPath, bulkDeleteParams)
    .reply(200, {});

  const errataScope = nockInstance
    .get(errataPath)
    .query(true)
    .reply(200, allErrata);

  const cvRequestCallbackScope = nockInstance
    .get(cvRefreshCallbackPath)
    .query(true)
    .reply(200, cvFilterDetails);

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { getByText, queryByText, getByLabelText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(errataId)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(errataId)).toBeInTheDocument();
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

  assertNockRequest(errataScope, done);
});

test('Can bulk add filter rules', async (done) => {
  const { rules } = cvFilterDetails;
  const errataId = rules[0].errata_id;

  const cvFilterScope = nockInstance
    .get(cvFilterDetailsPath)
    .query(true)
    .reply(200, cvFilterDetails);

  const cvFiltersScope = nockInstance
    .get(cvFiltersPath)
    .query(true)
    .reply(200, cvFilterFixtures);
  const bulkAddParams = { rules_params: [{ errata_ids: ['RHEA-2012:0056'] }, { errata_ids: ['RHEA-2012:0057'] }] };

  const cvFiltersRuleBulkAddScope = nockInstance
    .put(cvBulkAddFilterRulesPath, bulkAddParams)
    .reply(200, {});

  const errataScope = nockInstance
    .get(errataPath)
    .query(true)
    .reply(200, allErrata);

  const cvRequestCallbackScope = nockInstance
    .get(cvRefreshCallbackPath)
    .query(true)
    .reply(200, cvFilterDetails);

  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { getByText, queryByText, getByLabelText } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(errataId)).toBeNull();

  await patientlyWaitFor(() => {
    expect(getByText(errataId)).toBeInTheDocument();
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

  assertNockRequest(errataScope, done);
});

test('Can show filters and chips', async (done) => {
  const { rules, name: cvFilterName } = cvFilterDetails;
  const errataId = rules[0].errata_id;
  const cvFilterScope = nockInstance
    .get(cvFilterDetailsPath)
    .query(true)
    .reply(200, cvFilterDetails);
  const cvFiltersScope = nockInstance
    .get(cvFiltersPath)
    .query(true)
    .reply(200, cvFilterFixtures);
  const errataScope = nockInstance
    .get(errataPath)
    .times(5)
    .query(true)
    .reply(200, allErrata);
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const {
    getByText, getAllByText, queryByText, getByLabelText, getByTestId,
  } =
    renderWithRedux(withCVRoute(<ContentViewFilterDetails
      cvId={1}
      details={details}
    />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText(cvFilterName)).toBeNull();

  // Selected status filter
  await patientlyWaitFor(() => {
    expect(getByText(cvFilterName)).toBeInTheDocument();
    expect(getByTestId('allAddedNotAdded')).toBeInTheDocument();
    fireEvent.click(getByTestId('allAddedNotAdded')
      ?.childNodes[0]?.childNodes[1]?.childNodes[0]?.childNodes[0]);
  });

  await patientlyWaitFor(() => {
    expect(getByLabelText('select Added')).toBeInTheDocument();
    getByLabelText('select Added').click();
  });

  await patientlyWaitFor(() => {
    expect(getByText(errataId)).toBeInTheDocument();
    expect(queryByText('All')).not.toBeInTheDocument();
  });

  expect(getByText('Errata type')).toBeInTheDocument();
  getByText('Errata type').click();
  expect(getByLabelText('security_selection')).toBeInTheDocument();
  getByLabelText('security_selection').click();

  await patientlyWaitFor(() => {
    expect(getAllByText('ANY')).toHaveLength(2);
  });
  fireEvent.change(getByLabelText('start_date_input'), { target: { value: '08/15/1990' } });
  await patientlyWaitFor(() => {
    expect(getAllByText('ANY')).toHaveLength(1);
  });
  fireEvent.change(getByLabelText('end_date_input'), { target: { value: '08/15/2020' } });

  // expect(getByLabelText('blah')).toBeInTheDocument();
  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(errataScope); // 1st call on component load
  assertNockRequest(errataScope); // 2nd call on status selection
  assertNockRequest(errataScope); // 3rd call on errata type selection
  assertNockRequest(errataScope); // 4th call on start date change
  assertNockRequest(errataScope, done); // Last call on end date change
});
