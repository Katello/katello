export const SUBSCRIPTIONS_REQUEST = 'SUBSCRIPTIONS_REQUEST';
export const SUBSCRIPTIONS_SUCCESS = 'SUBSCRIPTIONS_SUCCESS';
export const SUBSCRIPTIONS_FAILURE = 'SUBSCRIPTIONS_FAILURE';

export const UPDATE_QUANTITY_REQUEST = 'UPDATE_QUANTITY_REQUEST';
export const UPDATE_QUANTITY_SUCCESS = 'UPDATE_QUANTITY_SUCCESS';
export const UPDATE_QUANTITY_FAILURE = 'UPDATE_QUANTITY_FAILURE';

export const SUBSCRIPTIONS_QUANTITIES_REQUEST = 'SUBSCRIPTIONS_QUANTITIES_REQUEST';
export const SUBSCRIPTIONS_QUANTITIES_SUCCESS = 'SUBSCRIPTIONS_QUANTITIES_SUCCESS';
export const SUBSCRIPTIONS_QUANTITIES_FAILURE = 'SUBSCRIPTIONS_QUANTITIES_FAILURE';

export const BLOCKING_FOREMAN_TASK_TYPES = [
  'Actions::Katello::Organization::ManifestImport',
  'Actions::Katello::Organization::ManifestRefresh',
  'Actions::Katello::Organization::ManifestDelete',
  'Actions::Katello::UpstreamSubscriptions::BindEntitlements',
  'Actions::Katello::UpstreamSubscriptions::UpdateEntitlement',
];

export const MANIFEST_TASKS_BULK_SEARCH_ID = 'activeManifestTasksSearch';
export const BULK_TASK_SEARCH_INTERVAL = 10000;
