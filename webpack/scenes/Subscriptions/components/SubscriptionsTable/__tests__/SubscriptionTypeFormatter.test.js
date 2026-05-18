import React from 'react';
import { render, screen } from '@testing-library/react';
import { subscriptionTypeFormatter } from '../SubscriptionTypeFormatter';

describe('subscriptionTypeFormatter', () => {
  const renderFormatter = (rowData) => {
    const content = (
      <table>
        <tbody>
          <tr>{subscriptionTypeFormatter(null, { rowData })}</tr>
        </tbody>
      </table>
    );
    return render(content);
  };

  it('renders physical subscriptions', () => {
    renderFormatter({ virt_only: false });
    expect(screen.getByText('Physical')).toBeInTheDocument();
  });

  it('renders temporary subscriptions', () => {
    renderFormatter({ unmapped_guest: true });
    expect(screen.getByText('Temporary')).toBeInTheDocument();
  });

  it('renders virtual subscriptions', () => {
    renderFormatter({});
    expect(screen.getByText('Virtual')).toBeInTheDocument();
  });

  it('renders link to a host', () => {
    renderFormatter({ hypervisor: { name: 'host.example.com', id: 83 } });

    expect(screen.getByText('Guests of')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'host.example.com' })).toHaveAttribute(
      'href',
      '/new/hosts/83/',
    );
  });
});
