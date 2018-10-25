import {
  quantitiesRequestSuccessResponse,
  loadQuantitiesSuccessActionPayload,
} from './subscriptions.fixtures';
import {
  filterRHSubscriptions,
  manifestExists,
  selectSubscriptionsQuantitiesFromResponse,
} from '../SubscriptionHelpers';

describe('Subscription helper', () => {
  it('should filter redhat subscriptions', () => {
    const subscriptions = [
      {
        key: 'sub-1',
        available: 0,
      },
      {
        key: 'sub-2',
        available: 4,
      },
      {
        key: 'sub-3',
        available: -5,
      },
      {
        key: 'sub-4',
        available: 100,
      },
    ];

    const filteredSubscriptions = filterRHSubscriptions(subscriptions);

    expect(filteredSubscriptions).toMatchSnapshot();
  });

  it('should check if manifest exists in an organization', () => {
    const upstreamConsumer = 'some-upstream-consumer';

    expect(manifestExists({
      owner_details: { upstreamConsumer },
    })).toBe(upstreamConsumer);

    expect(manifestExists({})).toBeFalsy();
  });

  it('should select subscriptions-quantities from api response', () => {
    const quantities =
      selectSubscriptionsQuantitiesFromResponse(quantitiesRequestSuccessResponse);

    expect(quantities).toEqual(loadQuantitiesSuccessActionPayload);
  });
});
