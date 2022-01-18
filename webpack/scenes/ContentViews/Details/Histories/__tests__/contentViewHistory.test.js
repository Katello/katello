import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';

import nock, { nockInstance, assertNockRequest, mockAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import CONTENT_VIEWS_KEY from '../../../ContentViewsConstants';
import ContentViewHistories from '../ContentViewHistories';
import historyData from './contentViewHistory.fixtures.json';

const renderOptions = { apiNamespace: `${CONTENT_VIEWS_KEY}_1` };
const cvHistories = api.getApiUrl('/content_views/1/history');
const autocompleteUrl = '/content_views/1/history/auto_complete_search';

let firstHistory;
let searchDelayScope;
let autoSearchScope;

beforeEach(() => {
  const { results } = historyData;
  [firstHistory] = results;
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 0);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing');
});

afterEach(() => {
  nock.cleanAll();
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
});

test('Can call API and show history on page load', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvHistories)
    .query(true)
    .reply(200, historyData);

  const { getByText, queryByText } = renderWithRedux(
    <ContentViewHistories cvId={1} />,
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(firstHistory.description)).toBeNull();
  // Assert that the repo name is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => expect(getByText(firstHistory.description)).toBeInTheDocument());
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Can link to view environment', async () => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(cvHistories)
    .query(true)
    .reply(200, historyData);

  const { getAllByText } = renderWithRedux(
    <ContentViewHistories cvId={1} />,
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(getAllByText('test')[0].closest('a'))
      .toHaveAttribute('href', '/lifecycle_environments/2');
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
});

test('Can handle no History being present', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const noResults = {
    total: 0,
    subtotal: 0,
    page: 1,
    per_page: 20,
    results: [],
  };
  const scope = nockInstance
    .get(cvHistories)
    .query(true)
    .reply(200, noResults);

  const { queryByText } = renderWithRedux(<ContentViewHistories cvId={1} />, renderOptions);

  expect(queryByText(firstHistory.description)).toBeNull();
  await patientlyWaitFor(() => expect(queryByText("You currently don't have any history for this content view.")).toBeInTheDocument());
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});
