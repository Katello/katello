import React from 'react';
import { screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { renderWithRedux } from 'react-testing-lib-wrapper';
import ProductsTab from '../ProductsTab';

const mockDetails = {
  gpg_key_products: [
    { id: 1, name: 'Test Product 1', cp_id: 'prod1' },
    { id: 2, name: 'Another Product', cp_id: 'prod2' },
  ],
  ssl_ca_products: [
    { id: 3, name: 'SSL Product', cp_id: 'ssl1' },
  ],
  ssl_client_products: [],
  ssl_key_products: [],
};

test('renders products table with correct data', () => {
  renderWithRedux(<ProductsTab details={mockDetails} />);

  expect(screen.getByText('Test Product 1')).toBeInTheDocument();
  expect(screen.getByText('Another Product')).toBeInTheDocument();
  expect(screen.getByText('SSL Product')).toBeInTheDocument();
});

test('filter functionality works correctly', () => {
  renderWithRedux(<ProductsTab details={mockDetails} />);

  // All products should be visible initially
  expect(screen.getByText('Test Product 1')).toBeInTheDocument();
  expect(screen.getByText('Another Product')).toBeInTheDocument();
  expect(screen.getByText('SSL Product')).toBeInTheDocument();

  // Find filter input and filter by "Test"
  const filterInput = screen.getByLabelText('Filter products');
  fireEvent.change(filterInput, { target: { value: 'Test' } });

  // Only "Test Product 1" should be visible
  expect(screen.getByText('Test Product 1')).toBeInTheDocument();
  expect(screen.queryByText('Another Product')).not.toBeInTheDocument();
  expect(screen.queryByText('SSL Product')).not.toBeInTheDocument();
});

test('shows empty state when no products', () => {
  const emptyDetails = {
    gpg_key_products: [],
    ssl_ca_products: [],
    ssl_client_products: [],
    ssl_key_products: [],
  };

  renderWithRedux(<ProductsTab details={emptyDetails} />);

  expect(screen.getByText('No products using this credential')).toBeInTheDocument();
});

test('shows no results message when filter matches nothing', () => {
  renderWithRedux(<ProductsTab details={mockDetails} />);

  const filterInput = screen.getByLabelText('Filter products');
  fireEvent.change(filterInput, { target: { value: 'NonexistentProduct' } });

  expect(screen.getByText('No matching products')).toBeInTheDocument();
  expect(screen.getByText('No products match your filter criteria.')).toBeInTheDocument();
});
