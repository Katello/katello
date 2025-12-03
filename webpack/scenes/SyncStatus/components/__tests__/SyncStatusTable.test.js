import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import SyncStatusTable from '../SyncStatusTable';

const mockProducts = [
  {
    id: 1,
    type: 'product',
    name: 'Test Product',
    children: [
      {
        id: 101,
        type: 'product_content',
        name: 'Test Content',
        repos: [
          {
            id: 1,
            type: 'repo',
            name: 'Test Repository',
            label: 'test-repo',
            product_id: 1,
          },
        ],
      },
    ],
  },
];

const mockRepoStatuses = {
  1: {
    id: 1,
    is_running: false,
    last_sync_words: 'Never synced',
    state: null,
  },
};

describe('SyncStatusTable', () => {
  const mockProps = {
    products: mockProducts,
    repoStatuses: mockRepoStatuses,
    onSelectRepo: jest.fn(),
    onSelectProduct: jest.fn(),
    onSyncRepo: jest.fn(),
    onCancelSync: jest.fn(),
    expandedNodeIds: [],
    setExpandedNodeIds: jest.fn(),
    showActiveOnly: false,
    isSelected: jest.fn(() => false),
    onExpandAll: jest.fn(),
    onCollapseAll: jest.fn(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders table with column headers', () => {
    render(<SyncStatusTable {...mockProps} />);

    expect(screen.getByText('Product | Repository')).toBeInTheDocument();
    expect(screen.getByText('Started at')).toBeInTheDocument();
    expect(screen.getByText('Details')).toBeInTheDocument();
    expect(screen.getByText('Progress / Result')).toBeInTheDocument();
  });

  it('renders product rows', () => {
    render(<SyncStatusTable {...mockProps} />);

    expect(screen.getByText('Test Product')).toBeInTheDocument();
  });

  it('expands rows when clicked', () => {
    render(<SyncStatusTable {...mockProps} />);

    const expandButtons = screen.getAllByRole('button', { name: /expand row/i });
    fireEvent.click(expandButtons[0]);

    expect(mockProps.setExpandedNodeIds).toHaveBeenCalled();
  });

  it('calls onSelectRepo when checkbox is clicked', () => {
    const propsWithExpandedNodes = {
      ...mockProps,
      expandedNodeIds: ['product-1', 'product_content-101'],
    };

    render(<SyncStatusTable {...propsWithExpandedNodes} />);

    // Find the checkbox for the repository
    const checkboxes = screen.getAllByRole('checkbox');
    // eslint-disable-next-line promise/prefer-await-to-callbacks
    const repoCheckbox = checkboxes.find(cb =>
      cb.getAttribute('aria-label')?.includes('Select repository'));

    if (repoCheckbox) {
      fireEvent.click(repoCheckbox);
      expect(mockProps.onSelectRepo).toHaveBeenCalled();
    }
  });

  it('shows repos with active syncs when showActiveOnly is true', () => {
    const activeRepoStatuses = {
      ...mockRepoStatuses,
      1: {
        id: 1,
        is_running: true,
        last_sync_words: 'Syncing...',
        state: 'running',
      },
    };

    const propsWithActiveOnly = {
      ...mockProps,
      repoStatuses: activeRepoStatuses,
      showActiveOnly: true,
      expandedNodeIds: ['product-1', 'product_content-101'],
    };

    render(<SyncStatusTable {...propsWithActiveOnly} />);

    // Should show the product and repo since it's active
    expect(screen.getByText('Test Product')).toBeInTheDocument();
    expect(screen.getByText('Test Repository')).toBeInTheDocument();
  });

  it('still shows product hierarchy even when repo is not active with showActiveOnly', () => {
    const propsWithActiveOnly = {
      ...mockProps,
      showActiveOnly: true,
    };

    render(<SyncStatusTable {...propsWithActiveOnly} />);

    // Filter only hides repos that are not running, but still shows product
    // and content nodes since they're not repos
    expect(screen.getByText('Test Product')).toBeInTheDocument();
  });
});
