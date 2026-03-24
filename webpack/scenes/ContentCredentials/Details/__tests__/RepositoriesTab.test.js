import React from 'react';
import { screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { renderWithRedux } from 'react-testing-lib-wrapper';
import RepositoriesTab from '../RepositoriesTab';

const mockDetails = {
  gpg_key_repos: [
    {
      id: 1,
      name: 'Test Repository',
      content_type: 'yum',
      product: { id: 1, name: 'Test Product 1' }
    },
    {
      id: 2,
      name: 'Another Repo',
      content_type: 'docker',
      product: { id: 2, name: 'Another Product' }
    },
  ],
  ssl_ca_root_repos: [
    {
      id: 3,
      name: 'SSL Repository',
      content_type: 'yum',
      product: { id: 3, name: 'SSL Product' }
    },
  ],
  ssl_client_root_repos: [],
  ssl_key_root_repos: [],
};

test('renders repositories table with correct data', () => {
  renderWithRedux(<RepositoriesTab details={mockDetails} />);

  expect(screen.getByText('Test Repository')).toBeInTheDocument();
  expect(screen.getByText('Another Repo')).toBeInTheDocument();
  expect(screen.getByText('SSL Repository')).toBeInTheDocument();
});

test('filter functionality works correctly', () => {
  renderWithRedux(<RepositoriesTab details={mockDetails} />);

  // All repos should be visible initially
  expect(screen.getByText('Test Repository')).toBeInTheDocument();
  expect(screen.getByText('Another Repo')).toBeInTheDocument();
  expect(screen.getByText('SSL Repository')).toBeInTheDocument();

  // Filter by content type "docker"
  const filterInput = screen.getByLabelText('Filter repositories');
  fireEvent.change(filterInput, { target: { value: 'docker' } });

  // Only "Another Repo" should be visible
  expect(screen.queryByText('Test Repository')).not.toBeInTheDocument();
  expect(screen.getByText('Another Repo')).toBeInTheDocument();
  expect(screen.queryByText('SSL Repository')).not.toBeInTheDocument();
});

test('shows empty state when no repositories', () => {
  const emptyDetails = {
    gpg_key_repos: [],
    ssl_ca_root_repos: [],
    ssl_client_root_repos: [],
    ssl_key_root_repos: [],
  };

  renderWithRedux(<RepositoriesTab details={emptyDetails} />);

  expect(screen.getByText('No repositories using this credential')).toBeInTheDocument();
});