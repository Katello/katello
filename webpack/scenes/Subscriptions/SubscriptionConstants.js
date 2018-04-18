export const SUBSCRIPTIONS_REQUEST = 'SUBSCRIPTIONS_REQUEST';
export const SUBSCRIPTIONS_SUCCESS = 'SUBSCRIPTIONS_SUCCESS';
export const SUBSCRIPTIONS_FAILURE = 'SUBSCRIPTIONS_FAILURE';

export const BLOCKING_FOREMAN_TASK_TYPES = [
  'Actions::Katello::Organization::ManifestImport',
  'Actions::Katello::Organization::ManifestRefresh',
  'Actions::Katello::Organization::ManifestDelete',
  'Actions::Katello::UpstreamSubscriptions::BindEntitlements',
];

export const MANIFEST_TASKS_BULK_SEARCH_ID = 'activeManifestTasksSearch';
