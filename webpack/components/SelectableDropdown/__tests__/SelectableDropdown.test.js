import React from 'react';
import { render } from 'react-testing-lib-wrapper';

import SelectableDropdown from '../SelectableDropdown';

const type = 'Breakfast';

test('Can dynamically load options', async () => {
  const { rerender, queryByText, queryByLabelText } = render(<SelectableDropdown
    items={[]}
    title={type}
    selected=""
    setSelected={jest.fn}
    placeholderText={type}
    loading
    error={false}
  />);
  expect(queryByLabelText(`${type} spinner`)).toBeInTheDocument();

  rerender(<SelectableDropdown
    items={['donut', 'croissant', 'bear claw']}
    title={type}
    selected=""
    setSelected={jest.fn}
    placeholderText={type}
    loading={false}
    error={false}
  />);
  expect(queryByLabelText(`${type} spinner`)).not.toBeInTheDocument();
  expect(queryByText('donut')).toBeInTheDocument();
});


test('Can handle error', async () => {
  const { queryByLabelText } = render(<SelectableDropdown
    items={[]}
    title={type}
    selected=""
    setSelected={jest.fn}
    placeholderText={type}
    loading={false}
    error
  />);
  expect(queryByLabelText(`${type} error`)).toBeInTheDocument();
});
