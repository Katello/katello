/* eslint-disable react/jsx-indent, react/jsx-closing-tag-location */
import React from 'react';
import { render, fireEvent } from '@testing-library/react';
import ProfileRpmCellFormatter from '../ProfileRpmsCellFormatter';
import { details } from '../../__tests__/moduleStreamDetails.fixtures';

describe('ProfileRpmCellFormatter', () => {
  const largeRpmList = details.profiles[0].rpms; // 13 RPMs
  const smallRpmList = details.profiles[1].rpms; // 1 RPM

  test('renders small list without expand/collapse icon', () => {
    const { container, getByText } = render(<table>
      <tbody>
        <tr>
          <ProfileRpmCellFormatter rpms={smallRpmList} />
        </tr>
      </tbody>
                                            </table>);

    // Should show the RPM name
    expect(getByText('python2-avocado')).toBeInTheDocument();

    // Should not have expand icon for small lists
    expect(container.querySelector('.expand-profile-rpms')).not.toBeInTheDocument();
  });

  test('renders large list with first 10 RPMs collapsed by default', () => {
    const { container, getByText } = render(<table>
      <tbody>
        <tr>
          <ProfileRpmCellFormatter rpms={largeRpmList} />
        </tr>
      </tbody>
                                            </table>);

    // Should show first 10 RPMs (indexes 0-9)
    expect(getByText(/perl/)).toBeInTheDocument();
    expect(getByText(/foo/)).toBeInTheDocument();
    expect(getByText(/rpm_0/)).toBeInTheDocument();
    expect(getByText(/rpm_5/)).toBeInTheDocument();

    // Should show ellipsis indicating more items
    expect(getByText(/\.\.\./)).toBeInTheDocument();

    // Should have expand icon
    const expandIcon = container.querySelector('.expand-profile-rpms');
    expect(expandIcon).toBeInTheDocument();
  });

  test('expands to show all RPMs when expand icon clicked', () => {
    const { container, getByText } = render(<table>
      <tbody>
        <tr>
          <ProfileRpmCellFormatter rpms={largeRpmList} />
        </tr>
      </tbody>
                                            </table>);

    // Initially collapsed - should show ellipsis
    expect(getByText(/\.\.\./)).toBeInTheDocument();

    // Click expand icon
    const expandIcon = container.querySelector('.expand-profile-rpms');
    fireEvent.click(expandIcon);

    // Should now show all RPMs including items beyond the first 10
    // (rpm_9 and rpm_10 are items 11-12)
    expect(getByText(/rpm_9/)).toBeInTheDocument();
    expect(getByText(/rpm_10/)).toBeInTheDocument();

    // Should not show ellipsis anymore
    expect(container.textContent).not.toMatch(/\.\.\./);

    // Icon should change to angle-down when expanded
    expect(container.querySelector('.fa-angle-down')).toBeInTheDocument();
  });

  test('collapses back to 10 RPMs when collapse icon clicked', () => {
    const { container, getByText } = render(<table>
      <tbody>
        <tr>
          <ProfileRpmCellFormatter rpms={largeRpmList} />
        </tr>
      </tbody>
    </table>);

    const expandIcon = container.querySelector('.expand-profile-rpms');

    // Expand first
    fireEvent.click(expandIcon);
    expect(getByText(/rpm_9/)).toBeInTheDocument();

    // Collapse again
    fireEvent.click(expandIcon);

    // Should show ellipsis again
    expect(getByText(/\.\.\./)).toBeInTheDocument();

    // Icon should be angle-right again
    expect(container.querySelector('.fa-angle-right')).toBeInTheDocument();
  });

  test('renders exactly 10 RPMs when collapsed', () => {
    const { container } = render(<table>
      <tbody>
        <tr>
          <ProfileRpmCellFormatter rpms={largeRpmList} />
        </tr>
      </tbody>
                                 </table>);

    const cellText = container.querySelector('td').textContent;
    // First 10 RPMs (indexes 0-9) from the fixture
    const expectedRpms = [
      'perl',
      'foo',
      'rpm_0',
      'rpm_1',
      'rpm_2',
      'rpm_3',
      'rpm_4',
      'rpm_5',
      'rpm_6',
      'rpm_7',
    ];

    expectedRpms.forEach((rpm) => {
      expect(cellText).toContain(rpm);
    });

    // Should show ellipsis
    expect(cellText).toContain('...');

    // Should NOT show items beyond the first 10 (items 11-13)
    expect(cellText).not.toContain('rpm_8');
    expect(cellText).not.toContain('rpm_9');
    expect(cellText).not.toContain('rpm_10');
  });

  test('displays RPMs as comma-separated list', () => {
    const { container } = render(<table>
      <tbody>
        <tr>
          <ProfileRpmCellFormatter rpms={smallRpmList} />
        </tr>
      </tbody>
                                 </table>);

    const cellText = container.querySelector('td').textContent;
    expect(cellText).toBe('python2-avocado');
  });

  test('displays multiple RPMs with commas', () => {
    const twoRpms = [
      { id: 1, name: 'first-package' },
      { id: 2, name: 'second-package' },
    ];

    const { container } = render(<table>
      <tbody>
        <tr>
          <ProfileRpmCellFormatter rpms={twoRpms} />
        </tr>
      </tbody>
                                 </table>);

    const cellText = container.querySelector('td').textContent;
    expect(cellText).toBe('first-package, second-package');
  });
});
