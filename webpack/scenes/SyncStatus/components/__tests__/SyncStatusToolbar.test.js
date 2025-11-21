import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
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

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders all action buttons', () => {
    render(<SyncStatusToolbar {...mockProps} />);

    expect(screen.getByText('Expand All')).toBeInTheDocument();
    expect(screen.getByText('Collapse All')).toBeInTheDocument();
    expect(screen.getByText('Select All')).toBeInTheDocument();
    expect(screen.getByText('Select None')).toBeInTheDocument();
    expect(screen.getByText('Synchronize Now')).toBeInTheDocument();
  });

  it('calls onSyncNow when Synchronize Now is clicked', () => {
    render(<SyncStatusToolbar {...mockProps} />);

    const syncButton = screen.getByText('Synchronize Now');
    fireEvent.click(syncButton);

    expect(mockProps.onSyncNow).toHaveBeenCalled();
  });

  it('disables Synchronize Now when no repos selected', () => {
    const props = { ...mockProps, selectedRepoIds: [] };
    render(<SyncStatusToolbar {...props} />);

    const syncButton = screen.getByText('Synchronize Now');
    expect(syncButton).toBeDisabled();
  });

  it('calls onExpandAll when Expand All is clicked', () => {
    render(<SyncStatusToolbar {...mockProps} />);

    const expandButton = screen.getByText('Expand All');
    fireEvent.click(expandButton);

    expect(mockProps.onExpandAll).toHaveBeenCalled();
  });

  it('toggles active only switch', () => {
    render(<SyncStatusToolbar {...mockProps} />);

    const activeOnlySwitch = screen.getByLabelText('Active Only');
    fireEvent.click(activeOnlySwitch);

    expect(mockProps.onToggleActiveOnly).toHaveBeenCalled();
  });
});
