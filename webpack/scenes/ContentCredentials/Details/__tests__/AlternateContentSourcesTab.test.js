import React from 'react';
import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { renderWithRedux } from 'react-testing-lib-wrapper';
import AlternateContentSourcesTab from '../AlternateContentSourcesTab';

const mockDetails = {
  ssl_ca_alternate_content_sources: [
    { id: 1, name: 'Test ACS 1' },
    { id: 2, name: 'Another ACS' },
  ],
  ssl_client_alternate_content_sources: [],
  ssl_key_alternate_content_sources: [],
};

test('renders alternate content sources table with correct data', () => {
  renderWithRedux(<AlternateContentSourcesTab details={mockDetails} />);

  expect(screen.getByText('Test ACS 1')).toBeInTheDocument();
  expect(screen.getByText('Another ACS')).toBeInTheDocument();
});

test('filter functionality works correctly', async () => {
  const user = userEvent.setup();
  renderWithRedux(<AlternateContentSourcesTab details={mockDetails} />);

  // All ACS should be visible initially
  expect(screen.getByText('Test ACS 1')).toBeInTheDocument();
  expect(screen.getByText('Another ACS')).toBeInTheDocument();

  // Filter by "Test"
  const filterInput = screen.getByPlaceholderText('Filter...');
  await user.type(filterInput, 'Test');

  // Only "Test ACS 1" should be visible
  expect(screen.getByText('Test ACS 1')).toBeInTheDocument();
  expect(screen.queryByText('Another ACS')).not.toBeInTheDocument();
});

test('shows empty state when no alternate content sources', () => {
  const emptyDetails = {
    ssl_ca_alternate_content_sources: [],
    ssl_client_alternate_content_sources: [],
    ssl_key_alternate_content_sources: [],
  };

  renderWithRedux(<AlternateContentSourcesTab details={emptyDetails} />);

  expect(screen.getByText('No alternate content sources using this credential')).toBeInTheDocument();
});

test('shows empty state when filter returns no matching alternate content sources', async () => {
  const user = userEvent.setup();
  renderWithRedux(<AlternateContentSourcesTab details={mockDetails} />);

  const filterInput = screen.getByPlaceholderText('Filter...');

  // Apply a filter that matches no alternate content sources
  await user.type(filterInput, 'non-matching-filter-text');

  expect(screen.getByText('No matching alternate content sources')).toBeInTheDocument();
});

test('ACS name links to the correct alternate content source page', () => {
  renderWithRedux(<AlternateContentSourcesTab details={mockDetails} />);

  const acs1Link = screen.getByRole('link', { name: 'Test ACS 1' });
  expect(acs1Link).toHaveAttribute('href', '/alternate_content_sources/1');

  const acs2Link = screen.getByRole('link', { name: 'Another ACS' });
  expect(acs2Link).toHaveAttribute('href', '/alternate_content_sources/2');
});
