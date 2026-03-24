import React from 'react';
import { screen, fireEvent } from '@testing-library/react';
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

test('filter functionality works correctly', () => {
  renderWithRedux(<AlternateContentSourcesTab details={mockDetails} />);

  // All ACS should be visible initially
  expect(screen.getByText('Test ACS 1')).toBeInTheDocument();
  expect(screen.getByText('Another ACS')).toBeInTheDocument();

  // Filter by "Test"
  const filterInput = screen.getByLabelText('Filter alternate content sources');
  fireEvent.change(filterInput, { target: { value: 'Test' } });

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