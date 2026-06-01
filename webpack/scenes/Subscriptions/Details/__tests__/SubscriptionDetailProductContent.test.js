import React from 'react';
import { render, screen } from '@testing-library/react';
import SubscriptionDetailProductContent from '../SubscriptionDetailProductContent';
import { availableContent, product } from '../../../Products/__tests__/products.fixtures.js';

describe('subscription detail product content page', () => {
  it('renders list items for enabled product content', () => {
    render(<SubscriptionDetailProductContent
      productContent={{ results: [product([availableContent])] }}
    />);

    expect(screen.getByText('Red Hat Enterprise Linux Server')).toBeInTheDocument();
  });

  it('renders empty state when there is no enabled product content', () => {
    render(<SubscriptionDetailProductContent productContent={{ results: [] }} />);

    expect(screen.getByText('No products are enabled.')).toBeInTheDocument();
  });
});
