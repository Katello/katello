import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { Route } from 'react-router-dom';

import { cvFilterDetailsKey } from '../../../ContentViewsConstants';
import nock, {
  nockInstance,
  assertNockRequest,
  mockAutocomplete,
  mockSetting,
} from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import CVContainerImageFilterContent from '../CVContainerImageFilterContent';
import cvFilterFixtures from './CVContainerImageFilterContent.fixtures.json';
import details from '../../../../ContentViews/__tests__/mockDetails.fixtures.json';

const afterDeleteFilterResultsArray = [...cvFilterFixtures.results];
afterDeleteFilterResultsArray.shift();
const { name: firstResultName } = cvFilterFixtures.results[0];
const { name: secondResultName } = cvFilterFixtures.results[1];
const cvFiltersUpdateDeletePath = api.getApiUrl('/content_view_filters/195/rules/35');
const cvFilterRulesPath = api.getApiUrl('/content_view_filters/195/rules');

const addedRule = {
  content_view_filter_id: 195,
  id: 99,
  name: 'walter',
  created_at: '2021-08-20 13:11:21 -0600',
  updated_at: '2021-08-20 13:11:21 -0600',
};

const autocompleteUrl = '/content_view_filters/195/rules/auto_complete_search';
const renderOptions = {
  apiNamespace: cvFilterDetailsKey(13, 195),
  routerParams: {
    initialEntries: [{ pathname: '/content_views/13#/filters/195' }],
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
  nock.cleanAll();
});

test('Can view container image filter rules', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const cvFiltersScope = nockInstance
    .get(cvFilterRulesPath)
    .query(true)
    .reply(200, cvFilterFixtures);


  const { queryByText, getByLabelText } =
    renderWithRedux(
      withCVRoute(<CVContainerImageFilterContent filterId={195} details={details} />),
      renderOptions,
    );

  // Nothing will show at first, page is loading
  expect(queryByText(firstResultName)).not.toBeInTheDocument();
  await patientlyWaitFor(() => {
    expect(queryByText(firstResultName)).toBeInTheDocument();
    expect(getByLabelText('Select all rows')).toBeInTheDocument();
    getByLabelText('Select all rows').click();
  });

  await patientlyWaitFor(() => {
    expect(getByLabelText('bulk_actions')).toBeInTheDocument();
    getByLabelText('bulk_actions').click();
    expect(getByLabelText('bulk_remove')).toHaveAttribute('aria-disabled', 'false');
  });


  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFiltersScope, done);
});

// Remove
test('Can remove filter rules', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const cvFiltersScope = nockInstance
    .get(cvFilterRulesPath)
    .query(true)
    .reply(200, cvFilterFixtures);

  const cvFilterDeleteScope = nockInstance
    .delete(cvFiltersUpdateDeletePath)
    .reply(200, {});

  const cvFiltersCallbackScope = nockInstance
    .get(cvFilterRulesPath)
    .query(true)
    .reply(200, { ...cvFilterFixtures, results: afterDeleteFilterResultsArray });

  const { queryByText, getAllByLabelText } =
    renderWithRedux(
      withCVRoute(<CVContainerImageFilterContent filterId={195} details={details} />),
      renderOptions,
    );

  // Nothing will show at first, page is loading
  expect(queryByText(firstResultName)).not.toBeInTheDocument();

  await patientlyWaitFor(() => {
    expect(queryByText(firstResultName)).toBeInTheDocument();
    expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'false');
  });

  fireEvent.click(getAllByLabelText('Actions')[0]);

  await patientlyWaitFor(() => {
    expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'true');
    expect(queryByText('Remove')).toBeInTheDocument();
    fireEvent.click(queryByText('Remove'));
  });

  await patientlyWaitFor(() => {
    expect(queryByText(secondResultName)).toBeInTheDocument();
    expect(queryByText(firstResultName)).not.toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvFilterDeleteScope);
  assertNockRequest(cvFiltersCallbackScope, done);
});


// Add
test('Can add filter rules', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const cvFiltersScope = nockInstance
    .get(cvFilterRulesPath)
    .query(true)
    .reply(200, cvFilterFixtures);

  const cvFilterAddScope = nockInstance
    .post(cvFilterRulesPath)
    .reply(200, addedRule);

  const cvFiltersCallbackScope = nockInstance
    .get(cvFilterRulesPath)
    .query(true)
    .reply(200, { ...cvFilterFixtures, results: [...cvFilterFixtures.results, addedRule] });

  const { queryByText, getByLabelText } =
    renderWithRedux(
      withCVRoute(<CVContainerImageFilterContent filterId={195} details={details} />),
      renderOptions,
    );

  // Nothing will show at first, page is loading
  expect(queryByText(firstResultName)).not.toBeInTheDocument();

  await patientlyWaitFor(() => {
    expect(queryByText(firstResultName)).toBeInTheDocument();
    fireEvent.click(getByLabelText('add_filter_rule'));
  });


  await patientlyWaitFor(() => {
    expect(getByLabelText('input_tag')).toBeInTheDocument();
  });

  fireEvent.change(getByLabelText('input_tag'), { target: { value: addedRule.name } });

  await patientlyWaitFor(() => {
    expect(getByLabelText('add_edit_filter_rule')).toBeInTheDocument();
    expect(getByLabelText('add_edit_filter_rule')).toHaveAttribute('aria-disabled', 'false');
  });

  fireEvent.submit(getByLabelText('input_tag'));

  await patientlyWaitFor(() => {
    expect(queryByText(addedRule.name)).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvFilterAddScope);
  assertNockRequest(cvFiltersCallbackScope, done);
});


// Edit
test('Can edit filter rules', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const cvFiltersScope = nockInstance
    .get(cvFilterRulesPath)
    .query(true)
    .reply(200, cvFilterFixtures);

  const cvFilterAddScope = nockInstance
    .put(cvFiltersUpdateDeletePath)
    .reply(200, addedRule);

  const cvFiltersCallbackScope = nockInstance
    .get(cvFilterRulesPath)
    .query(true)
    .reply(200, {
      ...cvFilterFixtures,
      results: cvFilterFixtures.results.map((result) => {
        if (result.name === firstResultName) {
          return { ...result, name: addedRule.name };
        }
        return result;
      }),
    });

  const { queryByText, getAllByLabelText, getByLabelText } =
    renderWithRedux(
      withCVRoute(<CVContainerImageFilterContent filterId={195} details={details} />),
      renderOptions,
    );

  // Nothing will show at first, page is loading
  expect(queryByText(firstResultName)).not.toBeInTheDocument();

  await patientlyWaitFor(() => {
    expect(queryByText(firstResultName)).toBeInTheDocument();
    expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'false');
  });

  fireEvent.click(getAllByLabelText('Actions')[0]);

  await patientlyWaitFor(() => {
    expect(getAllByLabelText('Actions')[0]).toHaveAttribute('aria-expanded', 'true');
    expect(queryByText('Edit')).toBeInTheDocument();
    fireEvent.click(queryByText('Edit'));
  });

  fireEvent.change(getByLabelText('input_tag'), { target: { value: addedRule.name } });

  await patientlyWaitFor(() => {
    expect(getByLabelText('add_edit_filter_rule')).toBeInTheDocument();
    expect(getByLabelText('add_edit_filter_rule')).toHaveAttribute('aria-disabled', 'false');
  });

  fireEvent.submit(getByLabelText('input_tag'));

  await patientlyWaitFor(() => {
    expect(queryByText(firstResultName)).not.toBeInTheDocument();
    expect(queryByText(addedRule.name)).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(cvFiltersScope);
  assertNockRequest(cvFilterAddScope);
  assertNockRequest(cvFiltersCallbackScope, done);
});
