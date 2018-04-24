import React from 'react';
import { render } from 'enzyme';
import toJson from 'enzyme-to-json';
import SubscriptionsTable from '../SubscriptionsTable';
import { successState, loadingState, emptyState } from './subscriptions.fixtures';
import { loadSubscriptions, updateQuantity } from '../SubscriptionActions';

describe('subscriptions table', () => {
  it('should render a table', async () => {
    const page = render(<SubscriptionsTable
      subscriptions={successState}
      loadSubscriptions={loadSubscriptions}
      updateQuantity={updateQuantity}
      subscriptionDeleteModalOpen={false}
      onSubscriptionDeleteModalClose={() => { }}
      onDeleteSubscriptions={() => {}}
      toggleDeleteButton={() => {}}
    />);
    expect(toJson(page)).toMatchSnapshot();
  });

  it('should render an empty state', async () => {
    const page = render(<SubscriptionsTable
      subscriptions={emptyState}
      loadSubscriptions={loadSubscriptions}
      updateQuantity={updateQuantity}
      subscriptionDeleteModalOpen={false}
      onSubscriptionDeleteModalClose={() => { }}
      onDeleteSubscriptions={() => {}}
      toggleDeleteButton={() => {}}
    />);
    expect(toJson(page)).toMatchSnapshot();
  });

  it('should render a loading state', async () => {
    const page = render(<SubscriptionsTable
      subscriptions={loadingState}
      loadSubscriptions={loadSubscriptions}
      updateQuantity={updateQuantity}
      subscriptionDeleteModalOpen={false}
      onSubscriptionDeleteModalClose={() => { }}
      onDeleteSubscriptions={() => {}}
      toggleDeleteButton={() => {}}
    />);
    expect(toJson(page)).toMatchSnapshot();
  });
});
