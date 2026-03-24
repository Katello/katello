import React from 'react';
import { render, act } from '@testing-library/react';
import ContentTable from '../ContentTable';

/* eslint-disable react/prop-types, react/no-array-index-key */
jest.mock('../../../components/pf3Table', () => ({
  Table: ({ rows, columns, emptyState }) => (
    <div>
      {rows && rows.length > 0 ? (
        <table>
          <thead>
            <tr>
              {columns.map((col, idx) => (
                <th key={idx}>{col.header ? col.header.label : ''}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((row, idx) => (
              <tr key={idx}>
                {columns.map((col, cIdx) => (
                  <td key={cIdx}>{row[col.property]}</td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      ) : (
        <div>{emptyState && emptyState.header}</div>
      )}
    </div>
  ),
}));
/* eslint-enable react/prop-types, react/no-array-index-key */

describe('ContentTable', () => {
  const tableSchema = [
    {
      property: 'content_name',
      header: { label: 'Name' },
    },
    {
      property: 'content_type',
      header: { label: 'Type' },
    },
    {
      property: 'content_version',
      header: { label: 'Version' },
    },
  ];

  const content = {
    loading: false,
    results: [
      { content_name: 'postgresql', content_type: 'rpm', content_version: '12.3' },
      { content_name: 'nginx', content_type: 'rpm', content_version: '1.18' },
      { content_name: 'redis', content_type: 'rpm', content_version: '6.0' },
      { content_name: 'nodejs', content_type: 'rpm', content_version: '14.17' },
      { content_name: 'python3', content_type: 'rpm', content_version: '3.9' },
    ],
    pagination: { page: 1, perPage: 20 },
    itemCount: 5,
  };

  const onPaginationChange = jest.fn();

  it('renders table content when loaded', () => {
    const { getAllByRole, getByText } = render(<ContentTable
      content={content}
      tableSchema={tableSchema}
      onPaginationChange={onPaginationChange}
    />);

    // Verify column headers
    const columnHeaders = getAllByRole('columnheader');
    expect(columnHeaders).toHaveLength(3);
    expect(columnHeaders[0]).toHaveTextContent('Name');
    expect(columnHeaders[1]).toHaveTextContent('Type');
    expect(columnHeaders[2]).toHaveTextContent('Version');

    // Verify row data
    expect(getByText('postgresql')).toBeInTheDocument();
    expect(getByText('nginx')).toBeInTheDocument();
    expect(getByText('redis')).toBeInTheDocument();
    expect(getByText('nodejs')).toBeInTheDocument();
    expect(getByText('python3')).toBeInTheDocument();
  });

  it('shows loading text when loading is true', () => {
    jest.useFakeTimers();
    const loadingContent = {
      ...content,
      loading: true,
    };

    const { getByText, queryByText } = render(<ContentTable
      content={loadingContent}
      tableSchema={tableSchema}
      onPaginationChange={onPaginationChange}
    />);

    act(() => { jest.advanceTimersByTime(300); });

    expect(getByText('Loading')).toBeInTheDocument();
    expect(queryByText('postgresql')).not.toBeInTheDocument();
    jest.useRealTimers();
  });

  it('shows empty state when there are no results', () => {
    const emptyContent = {
      loading: false,
      results: [],
      pagination: {},
      itemCount: 0,
    };

    const { getByText } = render(<ContentTable
      content={emptyContent}
      tableSchema={tableSchema}
      onPaginationChange={onPaginationChange}
    />);

    expect(getByText('No Content found')).toBeInTheDocument();
  });

  it('shows loading when results are undefined', () => {
    jest.useFakeTimers();
    const noResultsContent = {
      loading: false,
      results: undefined,
      pagination: {},
      itemCount: 0,
    };

    const { getByText } = render(<ContentTable
      content={noResultsContent}
      tableSchema={tableSchema}
      onPaginationChange={onPaginationChange}
    />);

    act(() => { jest.advanceTimersByTime(300); });

    // When results is undefined, the component treats it as loading
    expect(getByText('Loading')).toBeInTheDocument();
    jest.useRealTimers();
  });
});
