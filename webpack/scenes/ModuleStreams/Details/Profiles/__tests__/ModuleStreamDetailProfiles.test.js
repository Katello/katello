import React from 'react';
import { renderWithRedux } from 'react-testing-lib-wrapper';
import * as ContentSelectors from '../../../../Content/ContentSelectors';
import * as ContentActions from '../../../../Content/ContentActions';
import ModuleStreamDetailProfiles from '../ModuleStreamDetailProfiles';
import { details } from '../../__tests__/moduleStreamDetails.fixtures';

jest.mock('../../../../Content/ContentSelectors');
jest.mock('../../../../Content/ContentActions');

describe('Module stream detail profiles component', () => {
  const contentType = 'modulemd';
  const id = 22;

  beforeEach(() => {
    ContentSelectors.selectContentDetails.mockReturnValue(details);
    ContentSelectors.selectContentDetailsStatus.mockReturnValue('RESOLVED');
    ContentActions.getContentDetails.mockReturnValue({ type: 'GET_CONTENT_DETAILS' });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  test('renders table with profile data', () => {
    const component = <ModuleStreamDetailProfiles contentType={contentType} id={id} />;
    const { getByText, container } = renderWithRedux(component);

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
    const component = <ModuleStreamDetailProfiles contentType={contentType} id={id} />;
    const { container } = renderWithRedux(component);

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
    const component = <ModuleStreamDetailProfiles contentType={contentType} id={id} />;
    const { container } = renderWithRedux(component);

    // Verify both profiles are rendered (2 tbody rows expected)
    const tableRows = container.querySelectorAll('tbody tr');
    expect(tableRows).toHaveLength(2);
  });

  test('renders empty state when no profiles', () => {
    ContentSelectors.selectContentDetails.mockReturnValue({ profiles: [] });

    const component = <ModuleStreamDetailProfiles contentType={contentType} id={id} />;
    const { getByText } = renderWithRedux(component);

    // Should show "No profiles to show" message
    expect(getByText('No profiles to show')).toBeInTheDocument();
  });

  test('renders loading state when pending', () => {
    ContentSelectors.selectContentDetailsStatus.mockReturnValue('PENDING');

    const component = <ModuleStreamDetailProfiles contentType={contentType} id={id} />;
    const { getByText } = renderWithRedux(component);

    // Should show loading text
    expect(getByText('Loading')).toBeInTheDocument();
  });
});
