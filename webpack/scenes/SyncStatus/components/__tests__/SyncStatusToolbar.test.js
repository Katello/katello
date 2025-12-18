import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import SyncStatusToolbar from '../SyncStatusToolbar';

describe('SyncStatusToolbar', () => {
  const mockProps = {
    selectedRepoIds: [1, 2],
    onSyncNow: jest.fn(),
    showActiveOnly: false,
    onToggleActiveOnly: jest.fn(),
    selectAllCheckboxProps: {
      selectNone: jest.fn(),
      selectAll: jest.fn(),
      selectedCount: 2,
      totalCount: 10,
      areAllRowsSelected: false,
    },
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders toolbar with selection checkbox and sync button', () => {
    render(<SyncStatusToolbar {...mockProps} />);

    expect(screen.getByText('2 selected')).toBeInTheDocument();
    expect(screen.getByText('Synchronize')).toBeInTheDocument();
    // Switch renders label twice (on/off states), so use getAllByText
    expect(screen.getAllByText('Show syncing only').length).toBeGreaterThan(0);
  });

  it('calls onSyncNow when Synchronize is clicked', () => {
    render(<SyncStatusToolbar {...mockProps} />);

    const syncButton = screen.getByText('Synchronize');
    fireEvent.click(syncButton);

    expect(mockProps.onSyncNow).toHaveBeenCalled();
  });

  it('disables Synchronize when no repos selected', () => {
    const props = {
      ...mockProps,
      selectedRepoIds: [],
      selectAllCheckboxProps: {
        ...mockProps.selectAllCheckboxProps,
        selectedCount: 0,
      },
    };
    render(<SyncStatusToolbar {...props} />);

    const syncButton = screen.getByText('Synchronize');
    expect(syncButton).toBeDisabled();
  });

  it('toggles show syncing only switch', () => {
    render(<SyncStatusToolbar {...mockProps} />);

    const showSyncingSwitch = screen.getByLabelText('Show syncing only');
    fireEvent.click(showSyncingSwitch);

    expect(mockProps.onToggleActiveOnly).toHaveBeenCalled();
  });
});
