import React from 'react';
import { renderWithRouter } from 'react-testing-lib-wrapper';

import RoutedTabs from '../';

const tabs = [
  {
    key: 'apples',
    title: 'Apples',
    content: <>good for pies!</>,
  },
  {
    key: 'pears',
    title: 'Pears',
    content: <>good for a snack!</>,
  },
];

test('can render tabs and show default tab', async () => {
  const { getByText } = renderWithRouter(<RoutedTabs tabs={tabs} baseUrl="/fruits" defaultTabIndex={1} />);

  expect(getByText('Pears')).toBeInTheDocument();
  expect(getByText('good for a snack!')).toBeInTheDocument();
});

test('can switch tabs and render content', async () => {
  const { getByText } = renderWithRouter(<RoutedTabs tabs={tabs} baseUrl="/fruits" />);

  expect(getByText('good for pies!')).toBeInTheDocument();
  getByText('Pears').click();
  expect(getByText('good for a snack!')).toBeInTheDocument();
});
