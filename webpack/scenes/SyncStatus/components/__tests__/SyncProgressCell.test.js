import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import SyncProgressCell from '../SyncProgressCell';
import { SYNC_STATE_RUNNING } from '../../SyncStatusConstants';

describe('SyncProgressCell', () => {
  const mockOnCancelSync = jest.fn();

  const runningRepo = {
    id: 1,
    is_running: true,
    progress: { progress: 50 },
    raw_state: SYNC_STATE_RUNNING,
    sync_id: 12345,
  };

  let originalUrlPrefix;

  beforeEach(() => {
    jest.clearAllMocks();
    originalUrlPrefix = window.URL_PREFIX;
    window.URL_PREFIX = '';
  });

  afterEach(() => {
    window.URL_PREFIX = originalUrlPrefix;
  });

  it('renders progress bar when syncing', () => {
    render(<SyncProgressCell repo={runningRepo} onCancelSync={mockOnCancelSync} />);
    expect(screen.getByText('Syncing')).toBeInTheDocument();
  });

  it('links the progress bar to the sync task', () => {
    render(<SyncProgressCell repo={runningRepo} onCancelSync={mockOnCancelSync} />);

    const link = screen.getByRole('link');
    expect(link).toHaveAttribute('href', '/foreman_tasks/tasks/12345');
    expect(link).toHaveAttribute('target', '_blank');
    expect(link).toHaveAttribute('rel', 'noopener noreferrer');
    expect(link).toContainElement(screen.getByRole('progressbar'));
  });

  it('prefixes the task link with the Foreman URL prefix', () => {
    window.URL_PREFIX = '/foreman';
    render(<SyncProgressCell repo={runningRepo} onCancelSync={mockOnCancelSync} />);

    expect(screen.getByRole('link'))
      .toHaveAttribute('href', '/foreman/foreman_tasks/tasks/12345');
  });

  it.each([undefined, null])(
    'does not link the progress bar when sync_id is %p',
    (syncId) => {
      const repo = { ...runningRepo, sync_id: syncId };
      render(<SyncProgressCell repo={repo} onCancelSync={mockOnCancelSync} />);

      expect(screen.getByRole('progressbar')).toBeInTheDocument();
      expect(screen.queryByRole('link')).not.toBeInTheDocument();
    },
  );

  it('renders cancel button when syncing', () => {
    render(<SyncProgressCell repo={runningRepo} onCancelSync={mockOnCancelSync} />);
    const cancelButton = screen.getByLabelText('Cancel sync');
    expect(cancelButton).toBeInTheDocument();
  });

  it('calls onCancelSync when cancel button is clicked', () => {
    render(<SyncProgressCell repo={runningRepo} onCancelSync={mockOnCancelSync} />);

    const cancelButton = screen.getByLabelText('Cancel sync');
    expect(cancelButton.closest('a')).toBeNull();

    fireEvent.click(cancelButton);

    expect(mockOnCancelSync).toHaveBeenCalledWith(1);
  });

  it('does not render when not syncing', () => {
    const notRunningRepo = {
      ...runningRepo,
      is_running: false,
    };
    const { container } = render(<SyncProgressCell
      repo={notRunningRepo}
      onCancelSync={mockOnCancelSync}
    />);
    expect(container.firstChild).toBeNull();
  });
});
