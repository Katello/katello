import React from 'react';
import { render, fireEvent } from 'react-testing-lib-wrapper';
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
};

const emptyHostDetails = {
  host_collections: [],
};

test('shows host collections and host limits when present', () => {
  const { getByText } = render(<HostCollectionsCard hostDetails={hostDetails} />);
  expect(getByText('Host collections')).toBeInTheDocument();
  expect(getByText('Jturel hosts')).toBeInTheDocument();
  expect(getByText('1/43')).toBeInTheDocument();
  expect(getByText('1/1')).toBeInTheDocument();
  expect(getByText('2/unlimited')).toBeInTheDocument();
});

test('shows empty card when no host collections present', () => {
  const { queryByText } = render(<HostCollectionsCard hostDetails={emptyHostDetails} />);
  expect(queryByText('Host collections')).toBeInTheDocument();
  expect(queryByText('Jturel hosts')).not.toBeInTheDocument();
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

test('remove is disabled when no host collections present', () => {
  const { queryByLabelText } = render(<HostCollectionsCard hostDetails={emptyHostDetails} />);
  const kebab = queryByLabelText('host_collections_bulk_actions');
  expect(kebab).toBeInTheDocument();
  fireEvent.click(kebab);

  const remove = queryByLabelText('remove_host_from_collections');
  expect(remove).toBeInTheDocument();
  expect(remove).toHaveAttribute('aria-disabled', 'true');
});
