import React from 'react';
import { render, fireEvent } from '@testing-library/react';

import EnabledRepositoryContent from '../EnabledRepositoryContent';

describe('Enabled Repositories Content Component', () => {
  const getBaseProps = () => ({
    loading: false,
    disableTooltipId: 'disable-1',
    disableRepository: jest.fn(),
    canDisable: true,
  });

  describe('rendering', () => {
    test('renders without errors when enabled', () => {
      const { getByLabelText } = render(<EnabledRepositoryContent {...getBaseProps()} />);

      // Verify button is rendered and enabled (aria-disabled="false")
      const button = getByLabelText('Disable');
      expect(button).toBeInTheDocument();
      expect(button).toHaveAttribute('aria-disabled', 'false');
    });

    test('renders disabled state when canDisable is false', () => {
      const props = {
        ...getBaseProps(),
        canDisable: false,
      };
      const { getByLabelText } = render(<EnabledRepositoryContent {...props} />);

      // Verify button is rendered and aria-disabled
      const button = getByLabelText('Cannot be disabled');
      expect(button).toBeInTheDocument();
      expect(button).toHaveAttribute('aria-disabled', 'true');
    });

    test('renders loading spinner when loading', () => {
      const props = {
        ...getBaseProps(),
        loading: true,
      };
      const { container, queryByLabelText } = render(<EnabledRepositoryContent {...props} />);

      // Verify spinner is shown (check for pf-v5-c-spinner class)
      const spinner = container.querySelector('.pf-v5-c-spinner');
      expect(spinner).toBeInTheDocument();

      // Verify button is not shown
      expect(queryByLabelText('Disable')).not.toBeInTheDocument();
    });

    test('renders minus circle icon', () => {
      const { getByLabelText } = render(<EnabledRepositoryContent {...getBaseProps()} />);

      // Verify button with icon is rendered
      const button = getByLabelText('Disable');
      expect(button).toBeInTheDocument();

      // Verify the button contains an SVG icon
      const svg = button.querySelector('svg');
      expect(svg).toBeInTheDocument();
    });
  });

  describe('user interactions', () => {
    test('calls disableRepository when button clicked and canDisable is true', () => {
      const mockCallback = jest.fn();
      const props = {
        ...getBaseProps(),
        disableRepository: mockCallback,
        canDisable: true,
      };
      const { getByLabelText } = render(<EnabledRepositoryContent {...props} />);

      expect(mockCallback).not.toHaveBeenCalled();

      const button = getByLabelText('Disable');
      fireEvent.click(button);

      expect(mockCallback).toHaveBeenCalled();
    });

    test('does not call disableRepository when button is disabled', () => {
      const mockCallback = jest.fn();
      const props = {
        ...getBaseProps(),
        disableRepository: mockCallback,
        canDisable: false,
      };
      const { getByLabelText } = render(<EnabledRepositoryContent {...props} />);

      const button = getByLabelText('Cannot be disabled');
      fireEvent.click(button);

      // Button is disabled, so onClick shouldn't fire
      expect(mockCallback).not.toHaveBeenCalled();
    });

    test('does not render button when loading', () => {
      const mockCallback = jest.fn();
      const props = {
        ...getBaseProps(),
        disableRepository: mockCallback,
        loading: true,
      };
      const { queryByLabelText } = render(<EnabledRepositoryContent {...props} />);

      // Button doesn't exist when loading
      expect(queryByLabelText('Disable')).not.toBeInTheDocument();
      expect(mockCallback).not.toHaveBeenCalled();
    });
  });
});
