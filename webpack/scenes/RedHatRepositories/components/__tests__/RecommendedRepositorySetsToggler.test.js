import React from 'react';
import { render, fireEvent } from '@testing-library/react';

import RecommendedRepositorySetsToggler from '../RecommendedRepositorySetsToggler';

describe('RecommendedRepositorySetsToggler component', () => {
  const getBaseProps = () => ({
    enabled: false,
    onChange: jest.fn(),
  });

  describe('rendering', () => {
    test('renders without errors with default props', () => {
      const props = getBaseProps();
      const { container, getByText, getByLabelText } = render(<RecommendedRepositorySetsToggler
        {...props}
      />);
      expect(container.firstChild).toBeInTheDocument();

      // Verify default children text appears
      expect(getByText('Recommended Repositories')).toBeInTheDocument();

      // Verify star icon SVG is rendered
      const starIcon = container.querySelector('svg');
      expect(starIcon).toBeInTheDocument();

      // Verify Switch component is rendered
      const switchElement = getByLabelText('Recommended repositories toggle');
      expect(switchElement).toBeInTheDocument();
    });

    test('renders with enabled state', () => {
      const props = { ...getBaseProps(), enabled: true };
      const { getByLabelText } = render(<RecommendedRepositorySetsToggler {...props} />);

      // Verify Switch is in enabled state
      const switchElement = getByLabelText('Recommended repositories toggle');
      expect(switchElement).toBeChecked();
    });

    test('renders with disabled state', () => {
      const props = { ...getBaseProps(), enabled: false };
      const { getByLabelText } = render(<RecommendedRepositorySetsToggler {...props} />);

      // Verify Switch is in disabled state
      const switchElement = getByLabelText('Recommended repositories toggle');
      expect(switchElement).not.toBeChecked();
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

    test('renders help button', () => {
      const props = getBaseProps();
      const { getByLabelText } = render(<RecommendedRepositorySetsToggler {...props} />);

      // Verify help button is rendered
      const helpButton = getByLabelText('Help');
      expect(helpButton).toBeInTheDocument();
    });

    test('calls onChange when switch is toggled', () => {
      const mockOnChange = jest.fn();
      const props = { ...getBaseProps(), onChange: mockOnChange };
      const { getByLabelText } = render(<RecommendedRepositorySetsToggler {...props} />);

      const switchElement = getByLabelText('Recommended repositories toggle');
      fireEvent.click(switchElement);

      expect(mockOnChange).toHaveBeenCalledWith(true);
    });

    test('calls onChange with false when enabled and toggled', () => {
      const mockOnChange = jest.fn();
      const props = { ...getBaseProps(), enabled: true, onChange: mockOnChange };
      const { getByLabelText } = render(<RecommendedRepositorySetsToggler {...props} />);

      const switchElement = getByLabelText('Recommended repositories toggle');
      fireEvent.click(switchElement);

      expect(mockOnChange).toHaveBeenCalledWith(false);
    });
  });
});
