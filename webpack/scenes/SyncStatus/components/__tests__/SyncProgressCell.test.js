import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import SyncProgressCell from '../SyncProgressCell';
import { SYNC_STATE_RUNNING } from '../../SyncStatusConstants';

describe('SyncProgressCell', () => {
  const mockOnCancelSync = jest.fn();

  const runningRepo = {
    id: 1,
    is_running: true,
    progress: { progress: 50 },
    raw_state: SYNC_STATE_RUNNING,
  };

  it('renders progress bar when syncing', () => {
    render(<SyncProgressCell repo={runningRepo} onCancelSync={mockOnCancelSync} />);
    expect(screen.getByText('Syncing')).toBeInTheDocument();
  });

  it('renders cancel button when syncing', () => {
    render(<SyncProgressCell repo={runningRepo} onCancelSync={mockOnCancelSync} />);
    const cancelButton = screen.getByLabelText('Cancel sync');
    expect(cancelButton).toBeInTheDocument();
  });

  it('calls onCancelSync when cancel button is clicked', async () => {
    const user = userEvent.setup();
    render(<SyncProgressCell repo={runningRepo} onCancelSync={mockOnCancelSync} />);

    const cancelButton = screen.getByLabelText('Cancel sync');
    await user.click(cancelButton);

    expect(mockOnCancelSync).toHaveBeenCalledWith(1);
  });

  it('does not render when not syncing', () => {
    const notRunningRepo = {
      ...runningRepo,
      is_running: false,
    };
    const { container } = render(
      <SyncProgressCell repo={notRunningRepo} onCancelSync={mockOnCancelSync} />
    );
    expect(container.firstChild).toBeNull();
  });
});
