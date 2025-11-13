import React from 'react';
import { renderWithRedux } from 'react-testing-lib-wrapper';
import ManifestRepositoriesTable from '../ManifestRepositoriesTable';
import manifestDetailsData from '../Details/__tests__/manifestDetails.fixtures.json';

describe('ManifestRepositoriesTable', () => {
  const mockRepositories = manifestDetailsData.repositories;

  test('renders table with correct columns', () => {
    const { getByText } = renderWithRedux(<ManifestRepositoriesTable repositories={mockRepositories} tagName="v1.0" />);

    expect(getByText('Environment')).toBeInTheDocument();
    expect(getByText('Content view')).toBeInTheDocument();
    expect(getByText('Repository')).toBeInTheDocument();
    expect(getByText('Pullable path')).toBeInTheDocument();
  });

  test('displays repository data correctly', () => {
    const { getByText, getAllByText } = renderWithRedux(<ManifestRepositoriesTable repositories={mockRepositories} tagName="v1.0" />);

    expect(getAllByText('Library')[0]).toBeInTheDocument();
    expect(getByText('Default Organization View 1.0')).toBeInTheDocument();
    expect(getAllByText('ubi9-container')[0]).toBeInTheDocument();
  });

  test('renders repository as link', () => {
    const { getAllByText } = renderWithRedux(<ManifestRepositoriesTable repositories={mockRepositories} tagName="v1.0" />);

    const repoLink = getAllByText('ubi9-container')[0].closest('a');
    expect(repoLink).toHaveAttribute('href', '/products/5/repositories/10');
  });

  test('renders pullable path with tag name', () => {
    const { getByText } = renderWithRedux(<ManifestRepositoriesTable repositories={mockRepositories} tagName="v1.0" />);

    expect(getByText(/Default_Organization\/Library\/ubi9-container:v1.0/)).toBeInTheDocument();
  });

  test('handles empty repositories array', () => {
    const { getByText } = renderWithRedux(<ManifestRepositoriesTable repositories={[]} tagName="v1.0" />);

    expect(getByText('Environment')).toBeInTheDocument();
    expect(getByText('Content view')).toBeInTheDocument();
    expect(getByText('Repository')).toBeInTheDocument();
    expect(getByText('Pullable path')).toBeInTheDocument();
  });

  test('displays N/A when environment is null', () => {
    const repoWithoutEnv = [
      {
        id: 12,
        name: 'test-repo',
        full_path: 'Default_Organization/test-repo',
        library_instance: true,
        product_id: 7,
        product_name: 'Test Product',
        kt_environment: null,
        content_view_version: {
          id: 3,
          name: 'Test View 1.0',
          content_view_id: 3,
        },
      },
    ];

    const { getAllByText } = renderWithRedux(<ManifestRepositoriesTable repositories={repoWithoutEnv} tagName="v1.0" />);

    expect(getAllByText('N/A').length).toBeGreaterThan(0);
  });

  test('displays N/A when content view version is null', () => {
    const repoWithoutCV = [
      {
        id: 13,
        name: 'test-repo',
        full_path: 'Default_Organization/Library/test-repo',
        library_instance: true,
        product_id: 8,
        product_name: 'Test Product',
        kt_environment: {
          id: 1,
          name: 'Library',
        },
        content_view_version: null,
      },
    ];

    const { getAllByText } = renderWithRedux(<ManifestRepositoriesTable repositories={repoWithoutCV} tagName="v1.0" />);

    expect(getAllByText('N/A').length).toBeGreaterThan(0);
  });
});
