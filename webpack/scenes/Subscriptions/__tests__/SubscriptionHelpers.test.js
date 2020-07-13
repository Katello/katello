import {
  quantitiesRequestSuccessResponse,
  loadQuantitiesSuccessActionPayload,
} from './subscriptions.fixtures';
import {
  filterRHSubscriptions,
  selectSubscriptionsQuantitiesFromResponse,
} from '../SubscriptionHelpers';

describe('Subscription helper', () => {
  it('should filter subscriptions without upstream_pool_id', () => {
    const subscriptions = [
      {
        key: 'sub-1',
        available: 3,
      },
      {
        key: 'sub-2',
        available: 4,
        upstream_pool_id: ' ',
      },
      {
        key: 'sub-3',
        available: -5,
        upstream_pool_id: ' ',
      },
      {
        key: 'sub-4',
        available: -1,
      },
    ];

    const filteredSubscriptions = filterRHSubscriptions(subscriptions);

    expect(filteredSubscriptions).toMatchSnapshot();
  });

  it('should filter redhat subscriptions', () => {
    const subscriptions = [
      {
        key: 'sub-1',
        available: 0,
        upstream_pool_id: ' ',
      },
      {
        key: 'sub-2',
        available: 4,
        upstream_pool_id: ' ',
      },
      {
        key: 'sub-3',
        available: -5,
        upstream_pool_id: ' ',
      },
      {
        key: 'sub-4',
        available: 100,
        upstream_pool_id: ' ',
      },
    ];

    const filteredSubscriptions = filterRHSubscriptions(subscriptions);

    expect(filteredSubscriptions).toMatchSnapshot();
  });

  it('should select subscriptions-quantities from api response', () => {
    const quantities =
      selectSubscriptionsQuantitiesFromResponse(quantitiesRequestSuccessResponse);

    expect(quantities).toEqual(loadQuantitiesSuccessActionPayload);
  });
});
