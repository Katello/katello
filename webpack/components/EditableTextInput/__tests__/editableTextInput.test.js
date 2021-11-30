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

test('Passed function is called after editing and clicking submit', async () => {
  const mockEdit = jest.fn();
  const { getByLabelText } = render(<EditableTextInput {...defaultProps} onEdit={mockEdit} />);

  getByLabelText(`edit ${attribute}`).click();
  fireEvent.change(getByLabelText(`${attribute} text input`), { target: { value: actualValue } });
  getByLabelText(`submit ${attribute}`).click();

  await patientlyWaitFor(() => expect(mockEdit.mock.calls).toHaveLength(1));
  expect(mockEdit.mock.calls[0][0]).toBe(actualValue); // first arg
});

test('Passed function is called after editing and hitting enter', async () => {
  const mockEdit = jest.fn();
  const { getByLabelText } = render(<EditableTextInput {...defaultProps} onEdit={mockEdit} />);

  getByLabelText(`edit ${attribute}`).click();
  const textInputLabel = `${attribute} text input`;
  fireEvent.change(getByLabelText(textInputLabel), { target: { value: actualValue } });
  fireEvent.keyDown(getByLabelText(textInputLabel), { key: 'Enter', code: 'Enter' });

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

test('shows a mask over the password when there is one', () => {
  const { getByLabelText } = render(<EditableTextInput
    attribute={attribute}
    onEdit={jest.fn()}
    isPassword
    hasPassword
  />);

  expect(getByLabelText(`${attribute} text value`)).toHaveTextContent('••••••••');
});

test('shows a mask over the password after undoing changes', () => {
  const { getByLabelText } = render(<EditableTextInput
    attribute={attribute}
    onEdit={jest.fn()}
    isPassword
    hasPassword
  />);

  getByLabelText(`edit ${attribute}`).click();
  expect(getByLabelText(`${attribute} text input`)).toHaveTextContent('');

  getByLabelText(`clear ${attribute}`).click();
  expect(getByLabelText(`${attribute} text value`)).toHaveTextContent('••••••••');
});

test('shows a mask over the password after editing', async () => {
  const newPassword = 'Pizza';
  const { getByLabelText } = render(<EditableTextInput
    attribute={attribute}
    onEdit={jest.fn()}
    isPassword
    hasPassword
  />);

  getByLabelText(`edit ${attribute}`).click();
  fireEvent.change(getByLabelText(`${attribute} text input`), { target: { value: newPassword } });
  expect(getByLabelText(`${attribute} text input`)).toHaveValue(newPassword);
  getByLabelText(`submit ${attribute}`).click();

  await patientlyWaitFor(() => expect(getByLabelText(`${attribute} text value`)).toBeInTheDocument());
  expect(getByLabelText(`${attribute} text value`)).toHaveTextContent('••••••••');
});

test('shows a placeholder after clearing the password', async () => {
  const { getByLabelText } = render(<EditableTextInput
    attribute={attribute}
    onEdit={jest.fn()}
    isPassword
    hasPassword
  />);

  getByLabelText(`edit ${attribute}`).click();
  getByLabelText(`submit ${attribute}`).click();

  await patientlyWaitFor(() => expect(getByLabelText(`${attribute} text value`)).toBeInTheDocument());
  expect(getByLabelText(`${attribute} text value`)).toHaveTextContent('None provided');
});

test('can toggle showing the current password', async () => {
  const { getByLabelText } = render(<EditableTextInput
    attribute={attribute}
    onEdit={jest.fn()}
    isPassword
    hasPassword
  />);

  getByLabelText(`edit ${attribute}`).click();

  expect(getByLabelText(`show-password ${attribute}`)).toHaveAttribute('disabled', '');

  const newPassword = 'New Password';
  fireEvent.change(getByLabelText(`${attribute} text input`), { target: { value: newPassword } });
  expect(getByLabelText(`${attribute} text input`)).toHaveAttribute('type', 'password');

  getByLabelText(`show-password ${attribute}`).click();
  expect(getByLabelText(`${attribute} text input`)).toHaveAttribute('type', 'text');

  getByLabelText(`show-password ${attribute}`).click();
  expect(getByLabelText(`${attribute} text input`)).toHaveAttribute('type', 'password');
});
