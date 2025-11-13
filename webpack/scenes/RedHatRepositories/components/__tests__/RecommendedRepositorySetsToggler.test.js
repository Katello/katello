import React from 'react';
import { render } from '@testing-library/react';

import RecommendedRepositorySetsToggler from '../RecommendedRepositorySetsToggler';

describe('RecommendedRepositorySetsToggler component', () => {
  const getBaseProps = () => ({
    enabled: false,
    onChange: jest.fn(),
  });

  describe('rendering', () => {
    test('renders without errors with default props', () => {
      const props = getBaseProps();
      const { container, getByText } = render(<RecommendedRepositorySetsToggler {...props} />);
      expect(container.firstChild).toBeInTheDocument();

      // Verify default children text appears
      expect(getByText('Recommended Repositories')).toBeInTheDocument();

      // Verify star icon is rendered (legacy PF3 icon)
      const starIcon = container.querySelector('.fa-star');
      expect(starIcon).toBeInTheDocument();

      // Verify Switch component is rendered
      const switchDiv = container.querySelector('.bootstrap-switch');
      expect(switchDiv).toBeInTheDocument();
    });

    test('renders with enabled state', () => {
      const props = { ...getBaseProps(), enabled: true };
      const { container } = render(<RecommendedRepositorySetsToggler {...props} />);

      // Verify Switch is in enabled state by checking for the "on" class
      const switchContainer = container.querySelector('.bootstrap-switch');
      expect(switchContainer).toHaveClass('bootstrap-switch-on');
    });

    test('renders with disabled state', () => {
      const props = { ...getBaseProps(), enabled: false };
      const { container } = render(<RecommendedRepositorySetsToggler {...props} />);

      // Verify Switch is in disabled state by checking for the "off" class
      const switchContainer = container.querySelector('.bootstrap-switch');
      expect(switchContainer).toHaveClass('bootstrap-switch-off');
    });

    test('renders with custom children', () => {
      const props = { ...getBaseProps(), children: 'Custom Text' };
      const { getByText } = render(<RecommendedRepositorySetsToggler {...props} />);

      // Verify custom children text appears
      expect(getByText('Custom Text')).toBeInTheDocument();
    });

    test('renders with custom className', () => {
      const props = { ...getBaseProps(), className: 'custom-class-name' };
      const { container } = render(<RecommendedRepositorySetsToggler {...props} />);

      // Verify custom class is applied to the container
      const containerDiv = container.querySelector('.recommended-repositories-toggler-container');
      expect(containerDiv).toHaveClass('custom-class-name');
    });

    test('renders help icon', () => {
      const props = getBaseProps();
      const { container } = render(<RecommendedRepositorySetsToggler {...props} />);

      // Verify FieldLevelHelp icon is rendered (PF component)
      const helpIcon = container.querySelector('.pficon-info');
      expect(helpIcon).toBeInTheDocument();
    });

    test('renders with custom help text', () => {
      const props = { ...getBaseProps(), help: 'Custom help text' };
      const { container } = render(<RecommendedRepositorySetsToggler {...props} />);

      // Verify help icon is rendered (actual help text is in popover, hard to test)
      const helpIcon = container.querySelector('.pficon-info');
      expect(helpIcon).toBeInTheDocument();
    });
  });
});
