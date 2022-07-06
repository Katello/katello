import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { Route } from 'react-router-dom';

import ContentViewFilterDetails from '../ContentViewFilterDetails';
import { ADDED, cvFilterDetailsKey, NOT_ADDED } from '../../../ContentViewsConstants';
import {
  nockInstance,
  assertNockRequest,
  mockAutocomplete,
  mockSetting,
} from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import allModuleStreams from './allFilterModulesStreams.fixtures.json';
import cvFilterDetails from './cvModuleStreamFilterDetails.fixtures.json';
import cvFilterFixtures from './contentViewFilters.fixtures.json';
import details from '../../../__tests__/mockDetails.fixtures.json';

const cvFiltersPath = api.getApiUrl('/content_view_filters');
const cvRefreshCallbackPath = api.getApiUrl('/content_views/1');

const cvFilterDetailsPath = api.getApiUrl('/content_view_filters/8');
const cvAddFilterRulePath = api.getApiUrl('/content_view_filters/8/rules');
const cvRemoveFilterRulePath = api.getApiUrl('/content_view_filters/8/rules/13');
const cvBulkRemoveFilterRulesPath = api.getApiUrl('/content_view_filters/8/remove_filter_rules');
const cvBulkAddFilterRulesPath = api.getApiUrl('/content_view_filters/8/add_filter_rules');

const moduleStreamsPath = api.getApiUrl('/module_streams');
const autocompleteUrl = '/module_streams/auto_complete_search';
const renderOptions = {
  apiNamespace: cvFilterDetailsKey(1, 8),
  routerParams: {
    initialEntries: [{ pathname: '/content_views/1#/filters/8' }],
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
  const moduleStreamsScope = nockInstance
    .get(moduleStreamsPath)
    .query(true)
    .reply(200, allModuleStreams);
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
  assertNockRequest(moduleStreamsScope, done);
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

  const moduleStreamsScope = nockInstance
    .get(moduleStreamsPath)
    .query(true)
    .reply(200, allModuleStreams);

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

  assertNockRequest(moduleStreamsScope, done);
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

  const moduleStreamsScope = nockInstance
    .get(moduleStreamsPath)
    .query(true)
    .reply(200, allModuleStreams);

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

  assertNockRequest(moduleStreamsScope, done);
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

  const bulkDeleteParams = { rule_ids: [12, 13] };

  const cvFiltersRuleBulkDeleteScope = nockInstance
    .put(cvBulkRemoveFilterRulesPath, bulkDeleteParams)
    .reply(200, {});

  const moduleStreamsScope = nockInstance
    .get(moduleStreamsPath)
    .query(true)
    .reply(200, allModuleStreams);

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

  assertNockRequest(moduleStreamsScope, done);
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
  const bulkAddParams = { rules_params: [{ module_stream_ids: [10] }] };

  const cvFiltersRuleBulkAddScope = nockInstance
    .put(cvBulkAddFilterRulesPath, bulkAddParams)
    .reply(200, {});

  const moduleStreamsScope = nockInstance
    .get(moduleStreamsPath)
    .query(true)
    .reply(200, allModuleStreams);

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

  assertNockRequest(moduleStreamsScope, done);
});


test('Can filter by added/not added rules', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
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

  const moduleStreamsScope = nockInstance
    .get(moduleStreamsPath)
    .query(true)
    .times(3) // For first call (All), Added, and Not Added
    .reply(200, allModuleStreams);

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
    fireEvent.click(getByTestId('allAddedNotAdded')?.childNodes[0]?.childNodes[0]);
  });

  await patientlyWaitFor(() => {
    expect(getByLabelText(ADDED)).toBeInTheDocument();
    getByLabelText(ADDED).click();
  });

  await patientlyWaitFor(() => {
    expect(getByText(name)).toBeInTheDocument();
    expect(getByTestId('allAddedNotAdded')).toBeInTheDocument();
    fireEvent.click(getByTestId('allAddedNotAdded')?.childNodes[0]?.childNodes[0]);
  });

  await patientlyWaitFor(() => {
    expect(getByLabelText(NOT_ADDED)).toBeInTheDocument();
    getByLabelText(NOT_ADDED).click();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFilterScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(moduleStreamsScope, done);
});
