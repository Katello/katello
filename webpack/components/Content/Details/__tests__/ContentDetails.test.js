import React from 'react';
import { render } from '@testing-library/react';
import ContentDetailInfo from '../ContentDetailInfo';
import ContentDetailRepositories from '../ContentDetailRepositories';
import ContentDetails from '../ContentDetails';

describe('ContentDetails', () => {
  const detailInfo = {
    name: 'postgresql',
    version: '12.3',
  };

  const displayMap = new Map([
    ['name', 'Name'],
    ['version', 'Version'],
  ]);

  const repositories = [
    {
      id: 1,
      name: 'RHEL 8 BaseOS RPMs',
      product_id: 10,
      product_name: 'Red Hat Enterprise Linux 8',
    },
    {
      id: 2,
      name: 'RHEL 8 AppStream RPMs',
      product_id: 10,
      product_name: 'Red Hat Enterprise Linux 8',
    },
    {
      id: 3,
      name: 'EPEL 8 RPMs',
      product_id: 20,
      product_name: 'Extra Packages for Enterprise Linux',
    },
  ];

  const schema = [
    {
      key: 1,
      tabHeader: 'Details',
      tabContent: (
        <ContentDetailInfo contentDetails={detailInfo} displayMap={displayMap} />
      ),
    },
    {
      key: 2,
      tabHeader: 'Repositories',
      tabContent: (
        <ContentDetailRepositories repositories={repositories} />
      ),
    },
  ];

  it('renders tab headers from the schema', () => {
    const contentDetails = { loading: false, name: 'postgresql' };

    const { getByRole } = render(<ContentDetails
      contentDetails={contentDetails}
      schema={schema}
    />);

    expect(getByRole('tab', { name: 'Details' })).toBeInTheDocument();
    expect(getByRole('tab', { name: 'Repositories' })).toBeInTheDocument();
  });

  it('renders tab content including detail info and repositories', () => {
    const contentDetails = { loading: false, name: 'postgresql' };

    const {
      getAllByRole, getAllByText, getByRole, getByText,
    } = render(<ContentDetails contentDetails={contentDetails} schema={schema} />);

    // "Name" appears both as a detail info label and a repository column header
    expect(getAllByText('Name')).toHaveLength(2);
    // Verify the repository table has column headers (in inactive tab, so use hidden: true)
    const columnHeaders = getAllByRole('columnheader', { hidden: true });
    expect(columnHeaders[0]).toHaveTextContent('Name');
    expect(columnHeaders[1]).toHaveTextContent('Product');

    expect(getByText('postgresql')).toBeInTheDocument();
    expect(getByText('Version')).toBeInTheDocument();
    expect(getByText('12.3')).toBeInTheDocument();

    // Repositories content - verify links (in inactive tab, so use hidden: true)
    expect(getByRole('link', { name: 'RHEL 8 BaseOS RPMs', hidden: true })).toBeInTheDocument();
    // Two repos share the same product name
    expect(getAllByText('Red Hat Enterprise Linux 8')).toHaveLength(2);
  });

  it('shows no repository message when repositories are empty', () => {
    const contentDetails = { loading: false, name: 'postgresql' };
    const schemaWithNoRepos = [
      {
        key: 1,
        tabHeader: 'Details',
        tabContent: (
          <ContentDetailInfo contentDetails={detailInfo} displayMap={displayMap} />
        ),
      },
      {
        key: 2,
        tabHeader: 'Repositories',
        tabContent: 'No repositories to show',
      },
    ];

    const { getByText } = render(<ContentDetails
      contentDetails={contentDetails}
      schema={schemaWithNoRepos}
    />);

    expect(getByText('No repositories to show')).toBeInTheDocument();
  });

  it('shows loading state when loading is true', () => {
    const contentDetails = { loading: true, name: 'postgresql' };

    const { queryByText } = render(<ContentDetails
      contentDetails={contentDetails}
      schema={schema}
    />);

    // When loading is true, the LoadingState component delays rendering
    // and then shows a spinner, hiding the tab content
    expect(queryByText('Details')).not.toBeInTheDocument();
    expect(queryByText('Repositories')).not.toBeInTheDocument();
  });
});
