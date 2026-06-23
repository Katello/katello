import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import SubscriptionDetailProducts from '../SubscriptionDetailProducts';
import { successState } from './subscriptionDetails.fixtures';

describe('subscription detail product page', () => {
  it('renders provided products list', () => {
    render(<SubscriptionDetailProducts subscriptionDetails={successState} />);

    expect(screen.getByRole('heading', { name: 'Provided Products' })).toBeInTheDocument();
    expect(screen.getByText('Red Hat OpenShift Container Platform')).toBeInTheDocument();
    expect(screen.getByText('Red Hat JBoss Core Services')).toBeInTheDocument();

    // PF5 List renders list items
    const listItems = screen.getAllByRole('listitem');
    expect(listItems).toHaveLength(successState.provided_products.length);
  });
});
