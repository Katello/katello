import React from 'react';
import { render, fireEvent } from '@testing-library/react';
import OptionTooltip from '../';

const defaultProps = {
  icon: 'test',
  id: 'test',
  options: [],
  onClose: jest.fn(),
  onChange: jest.fn(),
};

test('OptionTooltip renders the trigger icon', () => {
  const { container } = render(<OptionTooltip {...defaultProps} />);
  const icon = container.querySelector('i.fa.test.tooltip-button');
  expect(icon).toBeInTheDocument();
});

test('OptionTooltip renders a list of options with default values after click', () => {
  const options = [
    { key: 'option1', value: true, label: 'One' },
    { key: 'option2', value: false, label: 'Two' },
  ];
  const { container, getByText } = render(<OptionTooltip {...defaultProps} options={options} />);

  const icon = container.querySelector('i.fa.test.tooltip-button');
  fireEvent.click(icon);

  expect(getByText('One')).toBeInTheDocument();
  expect(getByText('Two')).toBeInTheDocument();
});

test('calls onChange when checkbox is clicked', () => {
  const onChange = jest.fn();
  const options = [
    { key: 'option1', value: false, label: 'Option One' },
  ];
  const props = { ...defaultProps, options, onChange };
  const { container, getByRole } = render(<OptionTooltip {...props} />);

  const icon = container.querySelector('i.fa.test.tooltip-button');
  fireEvent.click(icon);

  const checkbox = getByRole('checkbox');
  fireEvent.click(checkbox);

  expect(onChange).toHaveBeenCalledWith([
    { key: 'option1', value: true, label: 'Option One' },
  ]);
});
