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
      const { container } = render(<EnabledRepositoryContent {...getBaseProps()} />);
      expect(container.firstChild).toBeInTheDocument();

      // For legacy PatternFly v3 button
      const button = container.querySelector('button');
      expect(button).toBeInTheDocument();
      expect(button).not.toBeDisabled();
    });

    test('renders disabled state when canDisable is false', () => {
      const props = {
        ...getBaseProps(),
        canDisable: false,
      };
      const { container } = render(<EnabledRepositoryContent {...props} />);

      // For legacy PatternFly v3 button
      const button = container.querySelector('button');
      expect(button).toBeInTheDocument();
      expect(button).toBeDisabled();
    });

    test('renders loading spinner when loading', () => {
      const props = {
        ...getBaseProps(),
        loading: true,
      };
      const { container } = render(<EnabledRepositoryContent {...props} />);
      expect(container.firstChild).toBeInTheDocument();
    });

    test('renders minus circle icon', () => {
      const { container } = render(<EnabledRepositoryContent {...getBaseProps()} />);

      // For legacy PatternFly v3 icon with aria-hidden
      const icon = container.querySelector('.fa-minus-circle');
      expect(icon).toBeInTheDocument();
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
      const { container } = render(<EnabledRepositoryContent {...props} />);

      expect(mockCallback).not.toHaveBeenCalled();

      // For legacy PatternFly v3 button
      const button = container.querySelector('button');
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
      const { container } = render(<EnabledRepositoryContent {...props} />);

      // For legacy PatternFly v3 button
      const button = container.querySelector('button');
      fireEvent.click(button);

      // Button is disabled, so onClick shouldn't fire
      expect(mockCallback).not.toHaveBeenCalled();
    });

    test('does not call disableRepository when loading', () => {
      const mockCallback = jest.fn();
      const props = {
        ...getBaseProps(),
        disableRepository: mockCallback,
        loading: true,
      };
      const { container } = render(<EnabledRepositoryContent {...props} />);

      // For legacy PatternFly v3 - button still exists but Spinner may affect behavior
      const button = container.querySelector('button');
      if (button) {
        fireEvent.click(button);
      }

      // Component is loading, callback shouldn't be triggered
      expect(mockCallback).not.toHaveBeenCalled();
    });
  });
});
