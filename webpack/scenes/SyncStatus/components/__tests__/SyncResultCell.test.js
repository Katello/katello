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
      state: 'Syncing complete',
    };
    render(<SyncResultCell repo={repo} />);
    expect(screen.getByText(/Syncing complete/i)).toBeInTheDocument();
  });

  it('renders error state correctly', () => {
    const repo = {
      raw_state: SYNC_STATE_ERROR,
      state: 'Sync incomplete',
      error_details: ['Connection timeout'],
    };
    render(<SyncResultCell repo={repo} />);
    expect(screen.getByText(/Sync incomplete/i)).toBeInTheDocument();
  });

  it('renders never synced state correctly', () => {
    const repo = {
      raw_state: SYNC_STATE_NEVER_SYNCED,
      state: 'Never synced',
    };
    render(<SyncResultCell repo={repo} />);
    expect(screen.getByText(/Never synced/i)).toBeInTheDocument();
  });

  it('renders task link when sync_id is present', () => {
    const repo = {
      raw_state: SYNC_STATE_STOPPED,
      state: 'Syncing complete',
      sync_id: '12345',
    };
    render(<SyncResultCell repo={repo} />);
    const link = screen.getByRole('link');
    expect(link).toHaveAttribute('href', expect.stringContaining('12345'));
  });
});
