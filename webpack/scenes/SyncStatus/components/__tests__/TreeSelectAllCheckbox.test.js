import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import TreeSelectAllCheckbox from '../TreeSelectAllCheckbox';

describe('TreeSelectAllCheckbox', () => {
  const mockProps = {
    selectNone: jest.fn(),
    selectAll: jest.fn(),
    selectedCount: 2,
    totalCount: 10,
    areAllRowsSelected: false,
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders with selected count', () => {
    render(<TreeSelectAllCheckbox {...mockProps} />);

    expect(screen.getByText('2 selected')).toBeInTheDocument();
  });

  it('calls selectAll when select all is clicked', () => {
    render(<TreeSelectAllCheckbox {...mockProps} />);

    // Click the dropdown toggle (aria-label is "Select")
    const dropdownToggle = screen.getByRole('button', { name: 'Select' });
    fireEvent.click(dropdownToggle);

    // Click select all option
    const selectAllOption = screen.getByText('Select all (10)');
    fireEvent.click(selectAllOption);

    expect(mockProps.selectAll).toHaveBeenCalled();
  });

  it('calls selectNone when select none is clicked', () => {
    render(<TreeSelectAllCheckbox {...mockProps} />);

    // Click the dropdown toggle (aria-label is "Select")
    const dropdownToggle = screen.getByRole('button', { name: 'Select' });
    fireEvent.click(dropdownToggle);

    // Click select none option
    const selectNoneOption = screen.getByText('Select none (0)');
    fireEvent.click(selectNoneOption);

    expect(mockProps.selectNone).toHaveBeenCalled();
  });

  it('shows indeterminate state when some items selected', () => {
    render(<TreeSelectAllCheckbox {...mockProps} />);

    const checkbox = screen.getByRole('checkbox');
    expect(checkbox).toBeInTheDocument();
  });

  it('disables select all when all rows are selected', () => {
    const propsAllSelected = {
      ...mockProps,
      selectedCount: 10,
      areAllRowsSelected: true,
    };

    render(<TreeSelectAllCheckbox {...propsAllSelected} />);

    // Click the dropdown toggle
    const dropdownToggle = screen.getByRole('button', { name: 'Select' });
    fireEvent.click(dropdownToggle);

    // Check that select all has aria-disabled
    const selectAllOption = screen.getByText('Select all (10)');
    expect(selectAllOption.closest('button')).toHaveAttribute('aria-disabled', 'true');
  });

  it('disables select none when no items are selected', () => {
    const propsNoneSelected = {
      ...mockProps,
      selectedCount: 0,
    };

    render(<TreeSelectAllCheckbox {...propsNoneSelected} />);

    // Click the dropdown toggle
    const dropdownToggle = screen.getByRole('button', { name: 'Select' });
    fireEvent.click(dropdownToggle);

    // Check that select none has aria-disabled
    const selectNoneOption = screen.getByText('Select none (0)');
    expect(selectNoneOption.closest('button')).toHaveAttribute('aria-disabled', 'true');
  });
});
