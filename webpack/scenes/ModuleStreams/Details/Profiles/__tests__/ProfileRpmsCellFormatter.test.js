/* eslint-disable react/jsx-indent, react/jsx-closing-tag-location */
import React from 'react';
import { render, fireEvent } from '@testing-library/react';
import ProfileRpmCellFormatter from '../ProfileRpmsCellFormatter';
import { details } from '../../__tests__/moduleStreamDetails.fixtures';

describe('ProfileRpmCellFormatter', () => {
  const largeRpmList = details.profiles[0].rpms; // 13 RPMs
  const smallRpmList = details.profiles[1].rpms; // 1 RPM

  test('renders small list without expand/collapse button', () => {
    const { container, getByText } = render(<table>
      <tbody>
        <tr>
          <td>
            <ProfileRpmCellFormatter rpms={smallRpmList} profileId={1} />
          </td>
        </tr>
      </tbody>
                                            </table>);

    // Should show the RPM name
    expect(getByText('python2-avocado')).toBeInTheDocument();

    // Should not have expand button for small lists
    expect(container.querySelector('.expand-profile-rpms')).not.toBeInTheDocument();
  });

  test('renders large list with first 10 RPMs collapsed by default', () => {
    const { container, getByText } = render(<table>
      <tbody>
        <tr>
          <td>
            <ProfileRpmCellFormatter rpms={largeRpmList} profileId={2} />
          </td>
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

    // Should have expand button with PF5 icon (AngleRightIcon)
    const expandButton = container.querySelector('.expand-profile-rpms');
    expect(expandButton).toBeInTheDocument();
    expect(expandButton.tagName).toBe('BUTTON');

    // Check for SVG icon (PF5 icons are SVG)
    expect(expandButton.querySelector('svg')).toBeInTheDocument();
  });

  test('expands to show all RPMs when expand button clicked', () => {
    const { container, getByText } = render(<table>
      <tbody>
        <tr>
          <td>
            <ProfileRpmCellFormatter rpms={largeRpmList} profileId={3} />
          </td>
        </tr>
      </tbody>
                                            </table>);

    // Initially collapsed - should show ellipsis
    expect(getByText(/\.\.\./)).toBeInTheDocument();

    // Click expand button
    const expandButton = container.querySelector('.expand-profile-rpms');
    fireEvent.click(expandButton);

    // Should now show all RPMs including items beyond the first 10
    // (rpm_9 and rpm_10 are items 11-12)
    expect(getByText(/rpm_9/)).toBeInTheDocument();
    expect(getByText(/rpm_10/)).toBeInTheDocument();

    // Should not show ellipsis anymore
    expect(container.textContent).not.toMatch(/\.\.\./);

    // Button should still be present (icon changed to AngleDownIcon)
    expect(expandButton).toBeInTheDocument();
    expect(expandButton.querySelector('svg')).toBeInTheDocument();
  });

  test('collapses back to 10 RPMs when collapse button clicked', () => {
    const { container, getByText } = render(<table>
      <tbody>
        <tr>
          <td>
            <ProfileRpmCellFormatter rpms={largeRpmList} profileId={4} />
          </td>
        </tr>
      </tbody>
    </table>);

    const expandButton = container.querySelector('.expand-profile-rpms');

    // Expand first
    fireEvent.click(expandButton);
    expect(getByText(/rpm_9/)).toBeInTheDocument();

    // Collapse again
    fireEvent.click(expandButton);

    // Should show ellipsis again
    expect(getByText(/\.\.\./)).toBeInTheDocument();

    // Button should still be present (icon changed back to AngleRightIcon)
    expect(expandButton).toBeInTheDocument();
    expect(expandButton.querySelector('svg')).toBeInTheDocument();
  });

  test('renders exactly 10 RPMs when collapsed', () => {
    const { container } = render(<table>
      <tbody>
        <tr>
          <td>
            <ProfileRpmCellFormatter rpms={largeRpmList} profileId={5} />
          </td>
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
          <td>
            <ProfileRpmCellFormatter rpms={smallRpmList} profileId={6} />
          </td>
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
          <td>
            <ProfileRpmCellFormatter rpms={twoRpms} profileId={7} />
          </td>
        </tr>
      </tbody>
                                 </table>);

    const cellText = container.querySelector('td').textContent;
    expect(cellText).toBe('first-package, second-package');
  });

  test('button has proper aria-label for accessibility', () => {
    const { container } = render(<table>
      <tbody>
        <tr>
          <td>
            <ProfileRpmCellFormatter rpms={largeRpmList} profileId={8} />
          </td>
        </tr>
      </tbody>
                                 </table>);

    const expandButton = container.querySelector('.expand-profile-rpms');

    // Should have aria-label
    expect(expandButton).toHaveAttribute('aria-label');
    expect(expandButton.getAttribute('aria-label')).toBe('Expand');

    // Click to expand
    fireEvent.click(expandButton);

    // Aria-label should change to 'Collapse'
    expect(expandButton.getAttribute('aria-label')).toBe('Collapse');
  });
});
