import React from 'react';
import { render, screen } from '@testing-library/react';
import SyncResultCell from '../SyncResultCell';
import {
  SYNC_STATE_STOPPED,
  SYNC_STATE_ERROR,
  SYNC_STATE_NEVER_SYNCED,
} from '../../SyncStatusConstants';

describe('SyncResultCell', () => {
  it('renders completed state correctly', () => {
    const repo = {
      raw_state: SYNC_STATE_STOPPED,
      state: 'Syncing Complete',
      start_time: '2 hours ago',
    };
    render(<SyncResultCell repo={repo} />);
    expect(screen.getByText(/Syncing Complete/)).toBeInTheDocument();
  });

  it('renders error state correctly', () => {
    const repo = {
      raw_state: SYNC_STATE_ERROR,
      state: 'Sync Incomplete',
      error_details: ['Connection timeout'],
    };
    render(<SyncResultCell repo={repo} />);
    expect(screen.getByText(/Sync Incomplete/)).toBeInTheDocument();
  });

  it('renders never synced state correctly', () => {
    const repo = {
      raw_state: SYNC_STATE_NEVER_SYNCED,
      state: 'Never Synced',
    };
    render(<SyncResultCell repo={repo} />);
    expect(screen.getByText(/Never Synced/)).toBeInTheDocument();
  });

  it('includes start time in the label', () => {
    const repo = {
      raw_state: SYNC_STATE_STOPPED,
      state: 'Syncing Complete',
      start_time: '3 hours ago',
    };
    render(<SyncResultCell repo={repo} />);
    expect(screen.getByText(/3 hours ago/)).toBeInTheDocument();
  });
});
