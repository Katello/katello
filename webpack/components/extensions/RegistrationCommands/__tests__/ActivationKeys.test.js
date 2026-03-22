import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import ActivationKeys from '../fields/ActivationKeys';

const getSelectToggleButton = () => document.querySelector('[data-ouia-component-id="activation-keys-field"] [aria-haspopup="listbox"]');

describe('ActivationKeys', () => {
  const mockOnChange = jest.fn();
  const mockHandleInvalidField = jest.fn();

  const defaultProps = {
    activationKeys: [],
    selectedKeys: [],
    hostGroupActivationKeys: [],
    hostGroupId: '',
    pluginValues: {},
    onChange: mockOnChange,
    handleInvalidField: mockHandleInvalidField,
    isLoading: false,
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders with label', () => {
    render(<ActivationKeys {...defaultProps} />);

    expect(screen.getByText('Activation Keys')).toBeInTheDocument();
  });

  it('shows placeholder when no activation keys available', () => {
    render(<ActivationKeys {...defaultProps} />);

    const input = screen.getByPlaceholderText('No Activation keys to select');
    expect(input).toBeInTheDocument();
  });

  it('disables select when no activation keys available', () => {
    render(<ActivationKeys {...defaultProps} />);

    expect(getSelectToggleButton()).toBeDisabled();
  });

  it('disables select when isLoading is true', () => {
    const propsWithKeys = {
      ...defaultProps,
      activationKeys: [{ name: 'key1' }],
      isLoading: true,
    };
    render(<ActivationKeys {...propsWithKeys} />);

    expect(getSelectToggleButton()).toBeDisabled();
  });

  it('enables select when activation keys are available', () => {
    const propsWithKeys = {
      ...defaultProps,
      activationKeys: [{ name: 'key1' }, { name: 'key2' }],
    };
    render(<ActivationKeys {...propsWithKeys} />);

    expect(getSelectToggleButton()).not.toBeDisabled();
  });

  it('shows "Create new activation key" link when no keys available', () => {
    render(<ActivationKeys {...defaultProps} />);

    expect(screen.getByText('Create new activation key')).toBeInTheDocument();
  });

  it('renders activation key options when dropdown is opened', () => {
    const propsWithKeys = {
      ...defaultProps,
      activationKeys: [
        { name: 'production-key', cves: 'Production/Library' },
        { name: 'dev-key', cves: 'Development/Library' },
      ],
    };
    render(<ActivationKeys {...propsWithKeys} />);

    fireEvent.click(getSelectToggleButton());

    expect(screen.getByText('production-key')).toBeInTheDocument();
    expect(screen.getByText('dev-key')).toBeInTheDocument();
  });

  it('calls onChange with selected key when a key is selected', () => {
    const propsWithKeys = {
      ...defaultProps,
      activationKeys: [
        { name: 'production-key', cves: 'Production/Library' },
        { name: 'dev-key', cves: 'Development/Library' },
      ],
      selectedKeys: [],
    };
    render(<ActivationKeys {...propsWithKeys} />);

    fireEvent.click(getSelectToggleButton());
    fireEvent.click(screen.getByText('production-key'));

    expect(mockOnChange).toHaveBeenCalledWith({
      activationKeys: ['production-key'],
    });
  });

  it('calls onChange with key removed when a key is deselected', () => {
    const propsWithKeys = {
      ...defaultProps,
      activationKeys: [
        { name: 'production-key', cves: 'Production/Library' },
        { name: 'dev-key', cves: 'Development/Library' },
      ],
      selectedKeys: ['production-key'],
    };
    render(<ActivationKeys {...propsWithKeys} />);

    fireEvent.click(getSelectToggleButton());
    fireEvent.click(screen.getByRole('option', { name: /production-key/i }));

    expect(mockOnChange).toHaveBeenCalledWith({
      activationKeys: [],
    });
  });

  it('shows selected keys as chips', () => {
    const propsWithSelection = {
      ...defaultProps,
      activationKeys: [{ name: 'key1' }, { name: 'key2' }],
      selectedKeys: ['key1'],
    };
    render(<ActivationKeys {...propsWithSelection} />);

    expect(screen.getByText('key1')).toBeInTheDocument();
  });

  it('calls handleInvalidField on mount', () => {
    render(<ActivationKeys {...defaultProps} />);

    expect(mockHandleInvalidField).toHaveBeenCalledWith('Activation Keys', expect.any(Boolean));
  });

  it('shows host group activation keys helper text', () => {
    const propsWithHostGroupKeys = {
      ...defaultProps,
      activationKeys: [{ name: 'key1' }],
      hostGroupActivationKeys: 'hg-key1,hg-key2',
      hostGroupId: 1,
      pluginValues: { activationKeys: ['key1'] },
    };
    render(<ActivationKeys {...propsWithHostGroupKeys} />);

    expect(screen.getByText('From host group: hg-key1,hg-key2')).toBeInTheDocument();
  });
});
