import React from 'react';
import { render } from '@testing-library/react';

import RepositoryTypeIcon from '../RepositoryTypeIcon';

describe('RepositoryTypeIcon component', () => {
  const getBaseProps = () => ({
    type: 'unknown-type',
  });

  describe('rendering', () => {
    test('renders without errors for unknown type', () => {
      const { getByLabelText } = render(<RepositoryTypeIcon {...getBaseProps()} />);

      // Verify it renders a question icon for unknown types
      const icon = getByLabelText('unknown-type repository type icon');
      expect(icon).toBeInTheDocument();
    });

    test('renders yum repository icon', () => {
      const props = { ...getBaseProps(), type: 'yum' };
      const { getByLabelText } = render(<RepositoryTypeIcon {...props} />);

      // Verify it renders the bundle icon for yum repositories
      const icon = getByLabelText('yum repository type icon');
      expect(icon).toBeInTheDocument();
    });

    test('renders file repository icon', () => {
      const props = { ...getBaseProps(), type: 'file' };
      const { getByLabelText } = render(<RepositoryTypeIcon {...props} />);

      // Verify it renders the file icon for file repositories
      const icon = getByLabelText('file repository type icon');
      expect(icon).toBeInTheDocument();
    });

    test('renders debug repository icon', () => {
      const props = { ...getBaseProps(), type: 'debug' };
      const { getByLabelText } = render(<RepositoryTypeIcon {...props} />);

      // Verify it renders the bug icon for debug repositories
      const icon = getByLabelText('debug repository type icon');
      expect(icon).toBeInTheDocument();
    });

    test('renders containerimage repository icon', () => {
      const props = { ...getBaseProps(), type: 'containerimage' };
      const { getByLabelText } = render(<RepositoryTypeIcon {...props} />);

      // Verify it renders the middleware icon for container image repositories
      const icon = getByLabelText('containerimage repository type icon');
      expect(icon).toBeInTheDocument();
    });

    test('renders kickstart repository icon', () => {
      const props = { ...getBaseProps(), type: 'kickstart' };
      const { getByLabelText } = render(<RepositoryTypeIcon {...props} />);

      // Verify it renders the futbol icon for kickstart repositories
      const icon = getByLabelText('kickstart repository type icon');
      expect(icon).toBeInTheDocument();
    });
  });
});
