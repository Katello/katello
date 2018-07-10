import React from 'react';
import { render } from 'enzyme';
import toJson from 'enzyme-to-json';
import { MemoryRouter } from 'react-router-dom';
import SubscriptionsTable from '../SubscriptionsTable';
import { successState, loadingState, emptyState } from '../../../__tests__/subscriptions.fixtures';
import { loadSubscriptions, updateQuantity } from '../../../SubscriptionActions';

describe('subscriptions table', () => {
  it('should render a table', async () => {
    // Wrapping SubscriptionTable in MemoryRouter here since it contains
    // a Link componenent, which can't be used outside a Router
    /* eslint-disable react/jsx-indent */
    const page = render(<MemoryRouter>
          <SubscriptionsTable
            subscriptions={successState}
            loadSubscriptions={loadSubscriptions}
            updateQuantity={updateQuantity}
            subscriptionDeleteModalOpen={false}
            onSubscriptionDeleteModalClose={() => { }}
            onDeleteSubscriptions={() => {}}
            toggleDeleteButton={() => {}}
          />
                        </MemoryRouter>);
    expect(toJson(page)).toMatchSnapshot();
  });

  it('should render an empty state', async () => {
    const emptyStateData = {
      header: __('Yay empty state'),
      description: __('There is nothing to see here'),
    };

    /* eslint-disable react/jsx-indent */
    const page = render(<MemoryRouter>
      <SubscriptionsTable
        subscriptions={emptyState}
        emptyState={emptyStateData}
        loadSubscriptions={loadSubscriptions}
        updateQuantity={updateQuantity}
        subscriptionDeleteModalOpen={false}
        onSubscriptionDeleteModalClose={() => {}}
        onDeleteSubscriptions={() => {}}
        toggleDeleteButton={() => {}}
      />
                        </MemoryRouter>);
    expect(toJson(page)).toMatchSnapshot();
  });
  /* eslint-enable react/jsx-indent */

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
