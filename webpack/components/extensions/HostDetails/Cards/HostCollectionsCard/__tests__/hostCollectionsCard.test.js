import React from 'react';
import { render, fireEvent, renderWithRedux } from 'react-testing-lib-wrapper';

import HostCollectionsCard from '../HostCollectionsCard';

const hostDetails = {
  host_collections: [
    {
      id: 1,
      name: 'Jer Hosts',
      description: null,
      max_hosts: null,
      unlimited_hosts: true,
      total_hosts: 2,
    },
    {
      id: 3,
      name: 'Partha hosts',
      description: null,
      max_hosts: 1,
      unlimited_hosts: false,
      total_hosts: 1,
    },
    {
      id: 2,
      name: 'Jturel hosts',
      description: 'This is my awesome description',
      max_hosts: 43,
      unlimited_hosts: false,
      total_hosts: 1,
    },
  ],
  subscription_facet_attributes: {
    uuid: '123',
  },
};

const emptyHostDetails = {
  host_collections: [],
  subscription_facet_attributes: {
    uuid: '123',
  },
};

const renderOptions = {
  initialState: {
    // This is the API state that your tests depend on for their data
    // You can cross reference the needed useSelectors from your tested components
    // with the data found within the redux chrome add-on to help determine this fixture data.
    katello: {
      hostDetails: {},
    },
  },
};

jest.mock('../../../hostDetailsHelpers', () => ({
  ...jest.requireActual('../../../hostDetailsHelpers'),
  userPermissionsFromHostDetails: () => ({
    view_host_collections: true,
    edit_hosts: true,
  }),
}));

test('shows host collections and host limits when present', () => {
  const { getByText } = render(<HostCollectionsCard hostDetails={hostDetails} />);
  expect(getByText('Host collections')).toBeInTheDocument();
  expect(getByText('Jturel hosts')).toBeInTheDocument();
  expect(getByText('1/43')).toBeInTheDocument();
  expect(getByText('1/1')).toBeInTheDocument();
  expect(getByText('2/unlimited')).toBeInTheDocument();
});

test('shows empty card when no host collections present', () => {
  const {
    queryByText,
    getByText,
    queryByLabelText,
  } = renderWithRedux(<HostCollectionsCard hostDetails={emptyHostDetails} />, renderOptions);
  expect(queryByText('Host collections')).toBeInTheDocument();
  expect(queryByText('Jturel hosts')).not.toBeInTheDocument();
  expect(getByText('No host collections yet')).toBeInTheDocument();
  expect(queryByLabelText('add_to_a_host_collection')).toBeInTheDocument();
});

test('expands to show description', () => {
  const { getByText, queryByText } = render(<HostCollectionsCard hostDetails={hostDetails} />);
  expect(getByText('Jturel hosts')).toBeInTheDocument();
  expect(queryByText('This is my awesome description')).not.toBeVisible();
  fireEvent.click(getByText('Jturel hosts'));
  expect(getByText('This is my awesome description')).toBeVisible();
});

test('expands to show when no description provided', () => {
  const { getAllByText, queryAllByText } = render(<HostCollectionsCard
    hostDetails={hostDetails}
  />);
  const indescribableHostCollection = getAllByText('Jer Hosts')[0];
  expect(indescribableHostCollection).toBeInTheDocument();
  queryAllByText('No description provided').forEach(element => expect(element).not.toBeVisible());
  fireEvent.click(indescribableHostCollection);
  expect(getAllByText('No description provided')[0]).toBeVisible();
});

test('shows add and remove options in kebab', () => {
  const { queryByLabelText } = render(<HostCollectionsCard hostDetails={hostDetails} />);
  const kebab = queryByLabelText('host_collections_bulk_actions');
  expect(kebab).toBeInTheDocument();
  fireEvent.click(kebab);

  const add = queryByLabelText('add_host_to_collections');
  const remove = queryByLabelText('remove_host_from_collections');

  expect(add).toBeInTheDocument();
  expect(remove).toBeInTheDocument();
  expect(add).toHaveAttribute('aria-disabled', 'false');
  expect(remove).toHaveAttribute('aria-disabled', 'false');
});

test('kebab is not displayed when no host collections present', () => {
  const {
    queryByLabelText,
  } = renderWithRedux(<HostCollectionsCard hostDetails={emptyHostDetails} />, renderOptions);
  const kebab = queryByLabelText('host_collections_bulk_actions');
  expect(kebab).not.toBeInTheDocument();
});

test('does not show card when host not registered', () => {
  const { queryByText } = render(<HostCollectionsCard
    hostDetails={{ ...emptyHostDetails, subscription_facet_attributes: undefined }}
  />);
  const cardTitle = queryByText('Host collections');
  expect(cardTitle).not.toBeInTheDocument();
});
