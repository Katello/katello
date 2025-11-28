import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { HOST_COLLECTIONS_KEY } from '../HostCollectionsConstants';
import HostCollectionsPage from '../HostCollectionsPage';
import api from '../../../services/api';
import {
  nockInstance,
  assertNockRequest,
} from '../../../test-utils/nockWrapper';
import hostCollectionsData from './hostCollectionsList.fixtures.json';

const hostCollectionsPath = api.getApiUrl('/host_collections');
const autocompleteUrl = '/host_collections/auto_complete_search';
const renderOptions = { apiNamespace: HOST_COLLECTIONS_KEY };

let firstCollection;
beforeEach(() => {
  const { results } = hostCollectionsData;
  [firstCollection] = results;
});

test('Can call API for Host Collections and show on screen on page load', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, []);

  const scope = nockInstance
    .get(hostCollectionsPath)
    .query(true)
    .reply(200, hostCollectionsData);

  const { queryByText } = renderWithRedux(
    <HostCollectionsPage />,
    renderOptions,
  );

  expect(queryByText(firstCollection.name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(queryByText(firstCollection.name)).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
});

test('Displays empty state when no host collections exist', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, []);

  const emptyCollectionsScope = nockInstance
    .get(hostCollectionsPath)
    .query(true)
    .reply(200, {
      total: 0,
      subtotal: 0,
      page: 1,
      per_page: 20,
      results: [],
    });

  const { queryByText } = renderWithRedux(
    <HostCollectionsPage />,
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(queryByText(/no results/i)).toBeInTheDocument();
  });

  assertNockRequest(emptyCollectionsScope);
  assertNockRequest(autocompleteScope);
});

test('Displays content host count and limit correctly', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(true)
    .reply(200, []);

  const scope = nockInstance
    .get(hostCollectionsPath)
    .query(true)
    .reply(200, hostCollectionsData);

  const { queryByText } = renderWithRedux(
    <HostCollectionsPage />,
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(queryByText('15')).toBeInTheDocument();
    expect(queryByText('Unlimited')).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
});
