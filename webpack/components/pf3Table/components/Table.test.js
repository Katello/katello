import React from 'react';
import { render, screen } from '@testing-library/react';
import Table from './Table';
import { columnsFixtures, rowsFixtures } from './TableFixtures';

jest.mock('foremanReact/components/common/EmptyState', () => ({
  __esModule: true,
  default: props => <div>Empty State: {props.header}</div>,
}));

jest.mock('foremanReact/components/Pagination', () => ({
  __esModule: true,
  default: () => <div>Pagination</div>,
}));

/* eslint-disable react/prop-types */
jest.mock('patternfly-react', () => ({
  Table: {
    PfProvider: ({ children }) => <table>{children}</table>,
    Header: () => <thead><tr><th>Header</th></tr></thead>,
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

describe('Table', () => {
  it('renders empty state when rows are empty', () => {
    const component = (
      <Table
        columns={columnsFixtures}
        rows={[]}
        emptyState={{ header: 'No items found' }}
      />
    );
    render(component);

    expect(screen.getByText('Empty State: No items found')).toBeInTheDocument();
  });

  it('renders children when provided', () => {
    const component = (
      <Table
        columns={columnsFixtures}
        rows={rowsFixtures}
      >
        <tbody><tr><td>some children</td></tr></tbody>
      </Table>
    );
    render(component);

    expect(screen.getByText('some children')).toBeInTheDocument();
  });

  it('renders body message', () => {
    const component = (
      <Table
        columns={columnsFixtures}
        rows={rowsFixtures}
        bodyMessage="some body message"
      />
    );
    render(component);

    expect(screen.getByText('some body message')).toBeInTheDocument();
  });

  it('renders pagination when itemCount and pagination are provided', () => {
    const component = (
      <Table
        columns={columnsFixtures}
        rows={rowsFixtures}
        itemCount={2}
        pagination={{ page: 1, perPage: 20 }}
      >
        <tbody><tr><td>some children</td></tr></tbody>
      </Table>
    );
    render(component);

    expect(screen.getByText('some children')).toBeInTheDocument();
    expect(screen.getByText('Pagination')).toBeInTheDocument();
  });

  it('does not render pagination when itemCount is not provided', () => {
    const component = (
      <Table
        columns={columnsFixtures}
        rows={rowsFixtures}
        pagination={{ page: 1, perPage: 20 }}
      >
        <tbody><tr><td>content</td></tr></tbody>
      </Table>
    );
    render(component);

    expect(screen.queryByText('Pagination')).not.toBeInTheDocument();
  });
});
