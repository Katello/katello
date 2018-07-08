import { find } from 'lodash';
import { MANIFEST_TASKS_BULK_SEARCH_ID } from './SubscriptionConstants';

export const filterRHSubscriptions = subscriptions =>
  subscriptions.filter(sub => sub.available >= 0);

export const manifestExists = organization =>
  organization.owner_details && organization.owner_details.upstreamConsumer;

export const selectSubscriptionsQuantitiesFromResponse = ({ results }) => {
  const quantityMap = {};

  results.forEach(pool =>
    pool.local_pool_ids && pool.local_pool_ids.forEach((localId) => {
      if (quantityMap[localId]) {
        quantityMap[localId] += pool.available;
      } else {
        quantityMap[localId] = pool.available;
      }
    }));

  return quantityMap;
};

export const filterManifestTasksFromBulkSearchResponse = (response) => {
  const search = find(response, bulkSearch =>
    bulkSearch.search_params.search_id === MANIFEST_TASKS_BULK_SEARCH_ID);

  if (search && search.results.length > 0) {
    return search.results;
  }

  return [];
};
