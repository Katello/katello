import React from 'react';
import { renderWithRouter } from 'react-testing-lib-wrapper';
import { head } from 'lodash';

import RoutedTabs from '../';

const tabs = [
  {
    key: 'apples',
    title: 'Apples',
    content: <>good for pies!</>,
    path: '/fruits',
  },
  {
    key: 'pears',
    title: 'Pears',
    content: <>good for a snack!</>,
    path: '/fruits',
  },
];

test('can render tabs and show default tab', async () => {
  const { getAllByLabelText, getByText } = renderWithRouter(<RoutedTabs tabs={tabs} baseUrl="/fruits" defaultTabIndex={1} />);
  expect(head(getAllByLabelText('Pears'))).toBeInTheDocument();
  expect(getByText('good for a snack!')).toBeInTheDocument();
});

test('falls back to an available tab when the requested tab is not configured', async () => {
  const { findByText, queryByText } = renderWithRouter(
    <RoutedTabs tabs={[tabs[0]]} />,
    { route: '/fruits#/restricted' },
  );
  expect(await findByText('good for pies!')).toBeInTheDocument();
  expect(queryByText('good for a snack!')).toBeNull();
});

test('preserves a valid directly linked tab', async () => {
  const { findByText, queryByText } = renderWithRouter(
    <RoutedTabs tabs={tabs} />,
    { route: '/fruits#/pears' },
  );
  expect(await findByText('good for a snack!')).toBeInTheDocument();
  expect(queryByText('good for pies!')).toBeNull();
});
