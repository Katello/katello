import React from 'react';
import { render, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import EditableTextInput from '../EditableTextInput';

const actualValue = 'burger';
const attribute = 'favorite_food';
const defaultProps = {
  onEdit: jest.fn(),
  value: actualValue,
  attribute,
};

test('Passed function is called after editing and submitting', async () => {
  const mockEdit = jest.fn();
  const { getByLabelText } = render(<EditableTextInput {...defaultProps} onEdit={mockEdit} />);

  getByLabelText(`edit ${attribute}`).click();
  fireEvent.change(getByLabelText(`${attribute} text input`), { target: { value: actualValue } });
  getByLabelText(`submit ${attribute}`).click();

  await patientlyWaitFor(() => expect(mockEdit.mock.calls).toHaveLength(1));
  expect(mockEdit.mock.calls[0][0]).toBe(actualValue); // first arg
});

test('input is set back to original value after clearing', () => {
  const value = 'Sandwich';
  const { getByLabelText } = render(<EditableTextInput {...defaultProps} />);

  // Show original value on load
  expect(getByLabelText(`${attribute} text value`)).toHaveTextContent(actualValue);
  getByLabelText(`edit ${attribute}`).click();
  // Update text input
  fireEvent.change(getByLabelText(`${attribute} text input`), { target: { value } });
  expect(getByLabelText(`${attribute} text input`)).toHaveValue(value);
  // Clear text
  getByLabelText(`clear ${attribute}`).click();
  // Original value is still showing even though it's been edited
  expect(getByLabelText(`${attribute} text value`)).toHaveTextContent(actualValue);
});
