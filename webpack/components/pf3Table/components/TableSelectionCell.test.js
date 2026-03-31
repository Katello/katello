import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import TableSelectionCell from './TableSelectionCell';

describe('TableSelectionCell', () => {
  it('renders a checked checkbox with before and after content', () => {
    const onChange = jest.fn();
    const component = (
      <table>
        <tbody>
          <tr>
            <TableSelectionCell
              id="some-id"
              before={<span>some before</span>}
              after={<span>some after</span>}
              label="some label"
              checked
              onChange={onChange}
            />
          </tr>
        </tbody>
      </table>
    );
    render(component);

    expect(screen.getByText('some before')).toBeInTheDocument();
    expect(screen.getByText('some after')).toBeInTheDocument();
    const checkbox = screen.getByRole('checkbox');
    expect(checkbox).toBeChecked();
  });

  it('hides the checkbox when hide is true', () => {
    const component = (
      <table>
        <tbody>
          <tr>
            <TableSelectionCell
              id="some-id"
              hide
            />
          </tr>
        </tbody>
      </table>
    );
    render(component);

    expect(screen.queryByRole('checkbox')).not.toBeInTheDocument();
  });

  it('calls onChange when checkbox is toggled', () => {
    const onChange = jest.fn();
    const component = (
      <table>
        <tbody>
          <tr>
            <TableSelectionCell
              id="some-id"
              checked={false}
              onChange={onChange}
            />
          </tr>
        </tbody>
      </table>
    );
    render(component);

    fireEvent.click(screen.getByRole('checkbox'));
    expect(onChange).toHaveBeenCalledTimes(1);
  });
});
