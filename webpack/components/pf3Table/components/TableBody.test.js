import React from 'react';
import { render, screen } from '@testing-library/react';
import TableBody from './TableBody';

/* eslint-disable react/prop-types */
jest.mock('patternfly-react', () => ({
  Table: {
    Body: ({ rows, rowKey }) => (
      <tbody>
        {rows.map((row, idx) => (
          <tr key={rowKey({ rowIndex: idx })}>
            <td>{row.id}</td>
            <td>{row.data}</td>
          </tr>
        ))}
      </tbody>
    ),
  },
}));
/* eslint-enable react/prop-types */

const columnsFixtures = [
  { property: 'id', header: { label: 'ID' } },
  { property: 'data', header: { label: 'Data' } },
];

const rowsFixtures = [
  { id: 1, data: 'data-1' },
  { id: 2, data: 'data-2' },
];

describe('TableBody', () => {
  it('renders table rows when no message is provided', () => {
    const component = (
      <table>
        <TableBody columns={columnsFixtures} rows={rowsFixtures} />
      </table>
    );
    render(component);

    expect(screen.getByText('data-1')).toBeInTheDocument();
    expect(screen.getByText('data-2')).toBeInTheDocument();
  });

  it('renders a message instead of rows when message is provided', () => {
    const component = (
      <table>
        <TableBody columns={columnsFixtures} rows={rowsFixtures} message="some message" />
      </table>
    );
    render(component);

    expect(screen.getByText('some message')).toBeInTheDocument();
    expect(screen.queryByText('data-1')).not.toBeInTheDocument();
  });
});
