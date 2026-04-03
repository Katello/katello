import React from 'react';
import { render, screen } from '@testing-library/react';
import TableBodyMessage from './TableBodyMessage';

describe('TableBodyMessage', () => {
  it('renders the message within a table body', () => {
    const component = (
      <table>
        <TableBodyMessage colSpan={2}>some children</TableBodyMessage>
      </table>
    );
    render(component);

    const cell = screen.getByText('some children').closest('td');
    expect(cell).toHaveAttribute('colspan', '2');
  });
});
