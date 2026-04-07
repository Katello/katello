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
      library_instance_id: 101,
      product: { id: 1, name: 'Test Product 1', cp_id: 'prod1' },
    },
    {
      id: 2,
      name: 'Another Repo',
      content_type: 'docker',
      library_instance_id: 102,
      product: { id: 2, name: 'Another Product', cp_id: 'prod2' },
    },
  ],
  ssl_ca_root_repos: [
    {
      id: 3,
      name: 'SSL Repository',
      content_type: 'yum',
      library_instance_id: 103,
      product: { id: 3, name: 'SSL Product', cp_id: 'ssl1' },
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
  const filterInput = screen.getByPlaceholderText('Filter...');
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

test('shows empty state when filter returns no matching repositories', () => {
  renderWithRedux(<RepositoriesTab details={mockDetails} />);

  const filterInput = screen.getByPlaceholderText('Filter...');

  // Apply a filter that matches no repositories
  fireEvent.change(filterInput, { target: { value: 'non-matching-filter-text' } });

  expect(screen.getByText('No matching repositories')).toBeInTheDocument();
});

test('repository name links to the correct repository page', () => {
  renderWithRedux(<RepositoriesTab details={mockDetails} />);

  const repoLink = screen.getByRole('link', { name: 'Test Repository' });
  expect(repoLink).toHaveAttribute('href', '/products/1/repositories/101');

  const anotherRepoLink = screen.getByRole('link', { name: 'Another Repo' });
  expect(anotherRepoLink).toHaveAttribute('href', '/products/2/repositories/102');
});

test('product name links to the correct product page', () => {
  renderWithRedux(<RepositoriesTab details={mockDetails} />);

  const productLinks = screen.getAllByRole('link', { name: 'Test Product 1' });
  expect(productLinks[0]).toHaveAttribute('href', '/products/1');

  const anotherProductLink = screen.getByRole('link', { name: 'Another Product' });
  expect(anotherProductLink).toHaveAttribute('href', '/products/2');
});
