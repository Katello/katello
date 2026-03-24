import React from 'react';
import { render } from '@testing-library/react';
import ContentDetailInfo from '../ContentDetailInfo';

describe('ContentDetailInfo', () => {
  const displayMap = new Map([
    ['name', 'Name'],
    ['version', 'Version'],
    ['description', 'Description'],
    ['arch', 'Architecture'],
    ['status', 'Status'],
  ]);

  const contentDetails = {
    name: 'postgresql',
    version: '12.3',
    description: 'PostgreSQL database server',
    arch: 'x86_64',
    status: 'Available',
  };

  it('renders a table with all detail fields and their labels', () => {
    const { getByText } = render(<ContentDetailInfo
      contentDetails={contentDetails}
      displayMap={displayMap}
    />);

    // Verify all labels are rendered
    expect(getByText('Name')).toBeInTheDocument();
    expect(getByText('Version')).toBeInTheDocument();
    expect(getByText('Description')).toBeInTheDocument();
    expect(getByText('Architecture')).toBeInTheDocument();
    expect(getByText('Status')).toBeInTheDocument();

    // Verify all values are rendered
    expect(getByText('postgresql')).toBeInTheDocument();
    expect(getByText('12.3')).toBeInTheDocument();
    expect(getByText('PostgreSQL database server')).toBeInTheDocument();
    expect(getByText('x86_64')).toBeInTheDocument();
    expect(getByText('Available')).toBeInTheDocument();
  });

  it('renders array values as comma-separated strings', () => {
    const arrayDisplayMap = new Map([
      ['tags', 'Tags'],
    ]);
    const arrayDetails = {
      tags: ['stable', 'production', 'lts'],
    };

    const { getByText } = render(<ContentDetailInfo
      contentDetails={arrayDetails}
      displayMap={arrayDisplayMap}
    />);

    expect(getByText('Tags')).toBeInTheDocument();
    expect(getByText('stable, production, lts')).toBeInTheDocument();
  });

  it('renders labels in bold', () => {
    const simpleMap = new Map([['name', 'Name']]);
    const simpleDetails = { name: 'test-package' };

    const { getByText } = render(<ContentDetailInfo
      contentDetails={simpleDetails}
      displayMap={simpleMap}
    />);

    const labelElement = getByText('Name');
    expect(labelElement.tagName).toBe('B');
  });
});
