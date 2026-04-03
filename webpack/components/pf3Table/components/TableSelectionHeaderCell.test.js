import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import TableSelectionHeaderCell from './TableSelectionHeaderCell';

describe('TableSelectionHeaderCell', () => {
  it('renders a checked checkbox with label', () => {
    const onChange = jest.fn();
    const component = (
      <table>
        <thead>
          <tr>
            <TableSelectionHeaderCell
              id="some-id"
              label="some label"
              checked
              onChange={onChange}
            />
          </tr>
        </thead>
      </table>
    );
    render(component);

    const checkbox = screen.getByRole('checkbox');
    expect(checkbox).toBeChecked();
  });

  it('renders an unchecked checkbox', () => {
    const component = (
      <table>
        <thead>
          <tr>
            <TableSelectionHeaderCell
              id="some-id"
              label="some label"
              checked={false}
              onChange={jest.fn()}
            />
          </tr>
        </thead>
      </table>
    );
    render(component);

    const checkbox = screen.getByRole('checkbox');
    expect(checkbox).not.toBeChecked();
  });

  it('calls onChange when checkbox is toggled', () => {
    const onChange = jest.fn();
    const component = (
      <table>
        <thead>
          <tr>
            <TableSelectionHeaderCell
              id="some-id"
              label="some label"
              checked={false}
              onChange={onChange}
            />
          </tr>
        </thead>
      </table>
    );
    render(component);

    fireEvent.click(screen.getByRole('checkbox'));
    expect(onChange).toHaveBeenCalledTimes(1);
  });
});
