import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest } from '../../../test-utils/nockWrapper';
import SyncStatusPage from '../SyncStatusPage';
import SYNC_STATUS_KEY from '../SyncStatusConstants';
import api from '../../../services/api';

const syncStatusPath = api.getApiUrl('/sync_status');
const renderOptions = { apiNamespace: SYNC_STATUS_KEY };

const mockSyncStatusData = {
  products: [
    {
      id: 1,
      type: 'product',
      name: 'Test Product',
      children: [
        {
          id: 1,
          type: 'repo',
          name: 'Test Repository',
          label: 'test-repo',
          product_id: 1,
        },
      ],
    },
  ],
  repo_statuses: {
    1: {
      id: 1,
      is_running: false,
      last_sync_words: 'Never synced',
    },
  },
};

test('Can call API for sync status and show on screen on page load', async () => {
  const scope = nockInstance
    .get(syncStatusPath)
    .query(true)
    .reply(200, mockSyncStatusData);

  const { queryByText } = renderWithRedux(<SyncStatusPage />, renderOptions);

  // Initially shouldn't show the product
  expect(queryByText('Test Product')).toBeNull();

  // Wait for data to load
  await patientlyWaitFor(() => {
    expect(queryByText('Sync Status')).toBeInTheDocument();
    expect(queryByText('Test Product')).toBeInTheDocument();
  });

  assertNockRequest(scope);
});

test('Displays toolbar with action buttons', async () => {
  const scope = nockInstance
    .get(syncStatusPath)
    .query(true)
    .reply(200, mockSyncStatusData);

  const { queryByText } = renderWithRedux(<SyncStatusPage />, renderOptions);

  await patientlyWaitFor(() => {
    expect(queryByText('Expand All')).toBeInTheDocument();
    expect(queryByText('Collapse All')).toBeInTheDocument();
    expect(queryByText('Select All')).toBeInTheDocument();
    expect(queryByText('Select None')).toBeInTheDocument();
    expect(queryByText('Synchronize Now')).toBeInTheDocument();
  });

  assertNockRequest(scope);
});

test('Displays empty state when no products exist', async () => {
  const emptyData = {
    products: [],
    repo_statuses: {},
  };

  const scope = nockInstance
    .get(syncStatusPath)
    .query(true)
    .reply(200, emptyData);

  const { queryByText } = renderWithRedux(<SyncStatusPage />, renderOptions);

  await patientlyWaitFor(() => {
    expect(queryByText('Sync Status')).toBeInTheDocument();
  });

  assertNockRequest(scope);
});
