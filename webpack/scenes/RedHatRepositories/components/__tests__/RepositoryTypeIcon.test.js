import React from 'react';
import { render } from '@testing-library/react';

import RepositoryTypeIcon from '../RepositoryTypeIcon';

describe('RepositoryTypeIcon component', () => {
  const getBaseProps = () => ({
    id: 123,
    type: 'unknown-type',
  });

  describe('rendering', () => {
    test('renders without errors for unknown type', () => {
      const { container } = render(<RepositoryTypeIcon {...getBaseProps()} />);
      expect(container.firstChild).toBeInTheDocument();

      // Verify it renders a question icon for unknown types (legacy PF3 icon)
      const icon = container.querySelector('.fa-question');
      expect(icon).toBeInTheDocument();
    });

    test('renders yum repository icon', () => {
      const props = { ...getBaseProps(), type: 'yum' };
      const { container } = render(<RepositoryTypeIcon {...props} />);
      expect(container.firstChild).toBeInTheDocument();

      // Verify it renders the PatternFly bundle icon for yum repositories
      const icon = container.querySelector('.pficon-bundle');
      expect(icon).toBeInTheDocument();
    });

    test('renders file repository icon', () => {
      const props = { ...getBaseProps(), type: 'file' };
      const { container } = render(<RepositoryTypeIcon {...props} />);
      expect(container.firstChild).toBeInTheDocument();

      // Verify it renders the file icon for file repositories
      const icon = container.querySelector('.fa-file');
      expect(icon).toBeInTheDocument();
    });

    test('renders debug repository icon', () => {
      const props = { ...getBaseProps(), type: 'debug' };
      const { container } = render(<RepositoryTypeIcon {...props} />);
      expect(container.firstChild).toBeInTheDocument();

      // Verify it renders the bug icon for debug repositories
      const icon = container.querySelector('.fa-bug');
      expect(icon).toBeInTheDocument();
    });

    test('renders containerimage repository icon', () => {
      const props = { ...getBaseProps(), type: 'containerimage' };
      const { container } = render(<RepositoryTypeIcon {...props} />);
      expect(container.firstChild).toBeInTheDocument();

      // Verify it renders the cube icon for container image repositories
      const icon = container.querySelector('.fa-cube');
      expect(icon).toBeInTheDocument();
    });

    test('renders kickstart repository icon', () => {
      const props = { ...getBaseProps(), type: 'kickstart' };
      const { container } = render(<RepositoryTypeIcon {...props} />);
      expect(container.firstChild).toBeInTheDocument();

      // Verify it renders the futbol icon for kickstart repositories
      const icon = container.querySelector('.fa-futbol-o');
      expect(icon).toBeInTheDocument();
    });
  });
});
