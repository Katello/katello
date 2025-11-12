import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import SyncStatusToolbar from '../SyncStatusToolbar';

describe('SyncStatusToolbar', () => {
  const mockProps = {
    selectedRepoIds: [1, 2],
    onSyncNow: jest.fn(),
    onExpandAll: jest.fn(),
    onCollapseAll: jest.fn(),
    onSelectAll: jest.fn(),
    onSelectNone: jest.fn(),
    showActiveOnly: false,
    onToggleActiveOnly: jest.fn(),
  };

  it('renders all action buttons', () => {
    render(<SyncStatusToolbar {...mockProps} />);

    expect(screen.getByText('Expand All')).toBeInTheDocument();
    expect(screen.getByText('Collapse All')).toBeInTheDocument();
    expect(screen.getByText('Select All')).toBeInTheDocument();
    expect(screen.getByText('Select None')).toBeInTheDocument();
    expect(screen.getByText('Synchronize Now')).toBeInTheDocument();
  });

  it('calls onSyncNow when Synchronize Now is clicked', async () => {
    const user = userEvent.setup();
    render(<SyncStatusToolbar {...mockProps} />);

    const syncButton = screen.getByText('Synchronize Now');
    await user.click(syncButton);

    expect(mockProps.onSyncNow).toHaveBeenCalled();
  });

  it('disables Synchronize Now when no repos selected', () => {
    const props = { ...mockProps, selectedRepoIds: [] };
    render(<SyncStatusToolbar {...props} />);

    const syncButton = screen.getByText('Synchronize Now');
    expect(syncButton).toBeDisabled();
  });

  it('calls onExpandAll when Expand All is clicked', async () => {
    const user = userEvent.setup();
    render(<SyncStatusToolbar {...mockProps} />);

    const expandButton = screen.getByText('Expand All');
    await user.click(expandButton);

    expect(mockProps.onExpandAll).toHaveBeenCalled();
  });

  it('toggles active only switch', async () => {
    const user = userEvent.setup();
    render(<SyncStatusToolbar {...mockProps} />);

    const activeOnlySwitch = screen.getByLabelText('Active Only');
    await user.click(activeOnlySwitch);

    expect(mockProps.onToggleActiveOnly).toHaveBeenCalled();
  });
});
