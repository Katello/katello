import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import Force from '../fields/Force';

describe('Force', () => {
  const mockOnChange = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders with label and tooltip icon', () => {
    render(<Force value={false} isLoading={false} onChange={mockOnChange} />);

    expect(screen.getByText('Force')).toBeInTheDocument();
    expect(screen.getByRole('checkbox')).toBeInTheDocument();
  });

  it('renders unchecked when value is false', () => {
    render(<Force value={false} isLoading={false} onChange={mockOnChange} />);

    const checkbox = screen.getByRole('checkbox');
    expect(checkbox).not.toBeChecked();
  });

  it('renders checked when value is true', () => {
    render(<Force value isLoading={false} onChange={mockOnChange} />);

    const checkbox = screen.getByRole('checkbox');
    expect(checkbox).toBeChecked();
  });

  it('calls onChange with toggled value when clicked', () => {
    render(<Force value={false} isLoading={false} onChange={mockOnChange} />);

    const checkbox = screen.getByRole('checkbox');
    fireEvent.click(checkbox);

    expect(mockOnChange).toHaveBeenCalledWith({ force: true });
  });

  it('is disabled when isLoading is true', () => {
    render(<Force value={false} isLoading onChange={mockOnChange} />);

    const checkbox = screen.getByRole('checkbox');
    expect(checkbox).toBeDisabled();
  });

  it('is enabled when isLoading is false', () => {
    render(<Force value={false} isLoading={false} onChange={mockOnChange} />);

    const checkbox = screen.getByRole('checkbox');
    expect(checkbox).not.toBeDisabled();
  });
});
