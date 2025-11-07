import React from 'react';
import { render } from '@testing-library/react';
import ModuleStreamDetailProfiles from '../ModuleStreamDetailProfiles';
import { details } from '../../__tests__/moduleStreamDetails.fixtures';

describe('Module stream detail profiles component', () => {
  // eslint-disable-next-line prefer-destructuring
  const { profiles } = details;

  test('renders table with profile data', () => {
    const { getByText, container } = render(<ModuleStreamDetailProfiles profiles={profiles} />);

    // Verify table headers
    expect(getByText('Name')).toBeInTheDocument();
    expect(getByText('RPMs')).toBeInTheDocument();

    // Verify both profile names appear
    expect(getByText('default')).toBeInTheDocument();
    expect(getByText('minimal')).toBeInTheDocument();

    // Verify table structure exists
    expect(container.querySelector('table')).toBeInTheDocument();
  });

  test('renders RPM names for each profile', () => {
    const { container } = render(<ModuleStreamDetailProfiles profiles={profiles} />);

    // Check that RPMs from the default profile are visible
    // The ProfileRpmsCellFormatter shows first 10 RPMs for the 'default' profile
    expect(container.textContent).toMatch(/perl/);
    expect(container.textContent).toMatch(/foo/);
    expect(container.textContent).toMatch(/rpm_0/);

    // Check for RPMs unique to each profile row
    const rows = container.querySelectorAll('tbody tr');
    expect(rows).toHaveLength(2);

    // First row should have the default profile with multiple RPMs
    const defaultRow = rows[0];
    expect(defaultRow.textContent).toContain('default');
    expect(defaultRow.textContent).toMatch(/perl.*foo.*rpm_0/);

    // Second row should have the minimal profile with single RPM
    const minimalRow = rows[1];
    expect(minimalRow.textContent).toContain('minimal');
    expect(minimalRow.textContent).toContain('python2-avocado');
  });

  test('renders multiple profiles from fixture data', () => {
    const { container } = render(<ModuleStreamDetailProfiles profiles={profiles} />);

    // Verify both profiles are rendered (2 tbody rows expected)
    const tableRows = container.querySelectorAll('tbody tr');
    expect(tableRows).toHaveLength(2);
  });

  test('renders with empty profiles array', () => {
    const { getByText } = render(<ModuleStreamDetailProfiles profiles={[]} />);

    // Table headers should still render
    expect(getByText('Name')).toBeInTheDocument();
    expect(getByText('RPMs')).toBeInTheDocument();
  });
});
