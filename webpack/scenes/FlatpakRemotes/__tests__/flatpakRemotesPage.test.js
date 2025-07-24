import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import FLATPAK_REMOTES_KEY from '../FlatpakRemotesConstants';
import FlatpakRemotesPage from '../FlatpakRemotesPage';
import api from '../../../services/api';
import { nockInstance, assertNockRequest } from '../../../test-utils/nockWrapper';
import flatpakRemotesData from './flatpakRemotesList.fixtures.json';

const flatpakRemotesPath = api.getApiUrl('/flatpak_remotes');
const autocompleteUrl = '/katello/api/v2/flatpak_remotes/auto_complete_search';
const renderOptions = { apiNamespace: FLATPAK_REMOTES_KEY };
const autocompleteQuery = {
  search: '',
};

let firstRemote;
beforeEach(() => {
  const { results } = flatpakRemotesData;
  [firstRemote] = results;
});

test('Can call API for Flatpak Remotes and show on screen on page load', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(autocompleteQuery)
    .reply(200, []);

  const scope = nockInstance
    .get(flatpakRemotesPath)
    .query(true)
    .times(2)
    .reply(200, flatpakRemotesData);

  const { queryByText } = renderWithRedux(<FlatpakRemotesPage />, renderOptions);

  expect(queryByText(firstRemote.name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(queryByText(firstRemote.name)).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
});

test('Displays empty state when no flatpak remotes exist', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(autocompleteQuery)
    .reply(200, []);

  const emptyRemotesScope = nockInstance
    .get(flatpakRemotesPath)
    .query(true)
    .times(2)
    .reply(200, {
      total: 0,
      subtotal: 0,
      page: 1,
      per_page: 20,
      results: [],
      can_create: true,
      can_view: true,
    });

  const { queryByText } = renderWithRedux(<FlatpakRemotesPage />, renderOptions);

  await patientlyWaitFor(() => {
    expect(queryByText(/no results/i)).toBeInTheDocument();
  });

  assertNockRequest(emptyRemotesScope);
  assertNockRequest(autocompleteScope);
});
