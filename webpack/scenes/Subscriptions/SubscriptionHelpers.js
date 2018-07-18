import { orgId } from '../../services/api';

export const filterRHSubscriptions = subscriptions =>
  subscriptions.filter(sub => sub.available >= 0);

export const manifestExists = organization =>
  organization.owner_details && organization.owner_details.upstreamConsumer;

export const selectSubscriptionsQuantitiesFromResponse = ({ results }) => {
  const quantityMap = {};

  results.forEach(pool =>
    pool.local_pool_ids &&
      pool.local_pool_ids.forEach((localId) => {
        if (quantityMap[localId]) {
          quantityMap[localId] += pool.available;
        } else {
          quantityMap[localId] = pool.available;
        }
      }));

  return quantityMap;
};

export const getAutoCompleteParams = search => ({
  endpoint: '/subscriptions/auto_complete_search',
  params: {
    organization_id: orgId(),
    search,
  },
});
