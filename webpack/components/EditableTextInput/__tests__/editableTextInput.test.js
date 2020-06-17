import React from 'react';
import { render, waitFor, fireEvent } from 'react-testing-lib-wrapper';
import EditableTextInput from '../EditableTextInput';

const actualValue = 'burger';
const label = 'Favorite Food';
const defaultProps = {
  onEdit: jest.fn(),
  value: actualValue,
  label,
};

test('Passed function is called after editing and submitting', () => {
  const mockEdit = jest.fn();
  const { getByLabelText } = render(<EditableTextInput {...defaultProps} onEdit={mockEdit} />);

  getByLabelText(/edit/i).click();
  fireEvent.change(getByLabelText(/text input/i), { target: { value: actualValue } });
  getByLabelText(/submit/i).click();

  expect(mockEdit.mock.calls).toHaveLength(1);
  expect(mockEdit.mock.calls[0][0]).toBe(actualValue); // first arg
});

test('input is set back to original value after clearing', async () => {
  const value = 'Sandwich';
  const { getByLabelText } = render(<EditableTextInput {...defaultProps} />);

  // Show original value on load
  expect(getByLabelText(/text value/i)).toHaveTextContent(actualValue);
  getByLabelText(/edit/i).click();
  // Update text input
  fireEvent.change(getByLabelText(/text input/i), { target: { value } });
  waitFor(() => expect(getByLabelText(/text input/i)).toHaveTextContent(value));
  // Clear text
  getByLabelText(/clear/i).click();
  // Original value is still showing even though it's been edited
  expect(getByLabelText(/text value/i)).toHaveTextContent(actualValue);
});

test('editable icon shows when editable is false', () => {
  const { queryByLabelText } = render(<EditableTextInput {...defaultProps} editable />);

  expect(queryByLabelText(`edit ${label}`)).toBeInTheDocument();
});

test('editable icon does not show when editable is false', () => {
  const { queryByLabelText } = render(<EditableTextInput {...defaultProps} editable={false} />);

  expect(queryByLabelText(`edit ${label}`)).not.toBeInTheDocument();
});
