/* eslint-disable function-paren-newline */
import React from 'react';
import { render } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import ContentTable from '../../../components/Content/ContentTable';
import TableSchema from '../../ModuleStreams/ModuleStreamsTableSchema';
import moduleStreamsData from './moduleStreams.fixtures.json';

// Mock LoadingState to avoid timing issues in tests
jest.mock('../../../components/LoadingState', () => ({
  // eslint-disable-next-line react/prop-types
  LoadingState: ({ loading, children }) => (
    loading ? <div>Loading...</div> : <>{children}</>
  ),
}));

// Mock Foreman EmptyState component
jest.mock('foremanReact/components/common/EmptyState', () => ({
  __esModule: true,
  default: ({ header }) => <div>{header}</div>,
}));

// Mock Foreman Pagination component
jest.mock('foremanReact/components/Pagination', () => ({
  __esModule: true,
  default: () => <div>Pagination</div>,
}));

describe('Module streams table', () => {
  const onPaginationChange = jest.fn();

  it('renders empty state when there are no module streams', () => {
    const moduleStreams = {
      loading: false,
      results: [],
      pagination: {},
      itemCount: 0,
    };

    const { getByText } = render(
      <MemoryRouter>
        <ContentTable
          content={moduleStreams}
          tableSchema={TableSchema}
          onPaginationChange={onPaginationChange}
        />
      </MemoryRouter>,
    );

    expect(getByText('No Content found')).toBeInTheDocument();
  });

  it('renders loading state when data is loading', () => {
    const moduleStreams = {
      loading: true,
      results: [],
      pagination: {},
      itemCount: 0,
    };

    const { getByText } = render(
      <MemoryRouter>
        <ContentTable
          content={moduleStreams}
          tableSchema={TableSchema}
          onPaginationChange={onPaginationChange}
        />
      </MemoryRouter>,
    );

    expect(getByText('Loading...')).toBeInTheDocument();
  });

  it('renders table with module streams data', () => {
    const moduleStreams = {
      loading: false,
      results: moduleStreamsData.results,
      pagination: { page: 1, perPage: 20 },
      itemCount: moduleStreamsData.total,
    };

    const { getByText } = render(
      <MemoryRouter>
        <ContentTable
          content={moduleStreams}
          tableSchema={TableSchema}
          onPaginationChange={onPaginationChange}
        />
      </MemoryRouter>,
    );

    // Verify column headers
    expect(getByText('Name')).toBeInTheDocument();
    expect(getByText('Stream')).toBeInTheDocument();
    expect(getByText('Version')).toBeInTheDocument();
    expect(getByText('Context')).toBeInTheDocument();
    expect(getByText('Arch')).toBeInTheDocument();

    // Verify data from fixtures is rendered (test multiple rows)
    expect(getByText('postgresql')).toBeInTheDocument();
    expect(getByText('10')).toBeInTheDocument();
    expect(getByText('ruby')).toBeInTheDocument();
    expect(getByText('2.5')).toBeInTheDocument();
    expect(getByText('nodejs')).toBeInTheDocument();
    expect(getByText('12')).toBeInTheDocument();
    expect(getByText('python36')).toBeInTheDocument();
    expect(getByText('3.6')).toBeInTheDocument();
    expect(getByText('mariadb')).toBeInTheDocument();
    expect(getByText('10.3')).toBeInTheDocument();

    // Verify version and context data (unique values from first row)
    expect(getByText('20180629154141')).toBeInTheDocument();
    expect(getByText('819b5873')).toBeInTheDocument();
  });
});

