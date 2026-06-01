import React from 'react';
import { render, screen } from '@testing-library/react';
import SubscriptionDetailProducts from '../SubscriptionDetailProducts';
import { successState } from './subscriptionDetails.fixtures';

describe('subscription detail product page', () => {
  it('renders provided products list', () => {
    const { container } = render(<SubscriptionDetailProducts subscriptionDetails={successState} />);

    expect(screen.getByRole('heading', { name: 'Provided Products' })).toBeInTheDocument();
    expect(screen.getByText('Red Hat OpenShift Container Platform')).toBeInTheDocument();
    expect(screen.getByText('Red Hat JBoss Core Services')).toBeInTheDocument();
    expect(container.querySelectorAll('li.list-group-item')).toHaveLength(successState.provided_products.length);
  });
});
