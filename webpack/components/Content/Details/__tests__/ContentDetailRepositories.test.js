import React from 'react';
import { render } from '@testing-library/react';
import ContentDetailRepositories from '../ContentDetailRepositories';

const createRepository = (overrides = {}) => ({
  id: 1,
  name: 'Default Repo',
  product_id: 10,
  product_name: 'Default Product',
  ...overrides,
});

describe('ContentDetailRepositories', () => {
  const repositories = [
    createRepository({
      id: 1, name: 'RHEL 8 BaseOS RPMs', product_id: 10, product_name: 'Red Hat Enterprise Linux 8',
    }),
    createRepository({
      id: 2, name: 'RHEL 8 AppStream RPMs', product_id: 10, product_name: 'Red Hat Enterprise Linux 8',
    }),
    createRepository({
      id: 3, name: 'EPEL 8 RPMs', product_id: 20, product_name: 'Extra Packages for Enterprise Linux',
    }),
    createRepository({
      id: 4, name: 'PostgreSQL 12 RPMs', product_id: 30, product_name: 'PostgreSQL',
    }),
    createRepository({
      id: 5, name: 'Ansible Runner RPMs', product_id: 40, product_name: 'Ansible Automation Platform',
    }),
  ];

  it('renders table headers for Name and Product', () => {
    const { getAllByRole } = render(<ContentDetailRepositories repositories={repositories} />);

    const columnHeaders = getAllByRole('columnheader');
    expect(columnHeaders).toHaveLength(2);
    expect(columnHeaders[0]).toHaveTextContent('Name');
    expect(columnHeaders[1]).toHaveTextContent('Product');
  });

  it('renders all repository names', () => {
    const { getByRole } = render(<ContentDetailRepositories repositories={repositories} />);

    expect(getByRole('link', { name: 'RHEL 8 BaseOS RPMs' })).toBeInTheDocument();
    expect(getByRole('link', { name: 'RHEL 8 AppStream RPMs' })).toBeInTheDocument();
    expect(getByRole('link', { name: 'EPEL 8 RPMs' })).toBeInTheDocument();
    expect(getByRole('link', { name: 'PostgreSQL 12 RPMs' })).toBeInTheDocument();
    expect(getByRole('link', { name: 'Ansible Runner RPMs' })).toBeInTheDocument();
  });

  it('renders product names for each repository', () => {
    const { getAllByText, getByText } = render(<ContentDetailRepositories
      repositories={repositories}
    />);

    // Two repos share the same product name
    expect(getAllByText('Red Hat Enterprise Linux 8')).toHaveLength(2);
    expect(getByText('Extra Packages for Enterprise Linux')).toBeInTheDocument();
    expect(getByText('PostgreSQL')).toBeInTheDocument();
    expect(getByText('Ansible Automation Platform')).toBeInTheDocument();
  });

  it('renders repository names as links to the correct product/repository URL', () => {
    const { getByRole } = render(<ContentDetailRepositories repositories={repositories} />);

    const repoLink = getByRole('link', { name: 'RHEL 8 BaseOS RPMs' });
    // urlBuilder appends a trailing slash
    expect(repoLink).toHaveAttribute('href', '/products/10/repositories/1/');
  });

  it('renders table headers but no rows when repositories is empty', () => {
    const { getAllByRole, queryByRole } = render(<ContentDetailRepositories repositories={[]} />);

    const columnHeaders = getAllByRole('columnheader');
    expect(columnHeaders).toHaveLength(2);
    expect(columnHeaders[0]).toHaveTextContent('Name');
    expect(columnHeaders[1]).toHaveTextContent('Product');
    expect(queryByRole('link')).not.toBeInTheDocument();
  });
});
