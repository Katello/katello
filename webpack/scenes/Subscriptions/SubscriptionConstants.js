import { translate as __ } from 'foremanReact/common/I18n';

export const SUBSCRIPTIONS = 'SUBSCRIPTIONS';
export const SUBSCRIPTIONS_TABLE_KEY = 'SUBSCRIPTIONS_TABLE';
export const SUBSCRIPTIONS_QUANTITIES_KEY = 'SUBSCRIPTIONS_QUANTITIES';
export const UPDATE_QUANTITY_KEY = 'UPDATE_QUANTITY';
export const DELETE_SUBSCRIPTIONS_KEY = 'DELETE_SUBSCRIPTIONS';

export const SUBSCRIPTIONS_SERVICE_DOC_URL = 'https://access.redhat.com/documentation/en-us/subscription_central/2021/html-single/getting_started_with_the_subscriptions_service/index';
export const SUBSCRIPTIONS_SERVICE_URL = 'https://console.redhat.com/subscriptions';

export const MANIFEST_DELETE_TASK_LABEL = 'Actions::Katello::Organization::ManifestDelete';

export const BLOCKING_FOREMAN_TASK_TYPES = [
  'Actions::Katello::Organization::ManifestImport',
  'Actions::Katello::Organization::ManifestRefresh',
  MANIFEST_DELETE_TASK_LABEL,
  'Actions::Katello::UpstreamSubscriptions::BindEntitlements',
  'Actions::Katello::UpstreamSubscriptions::UpdateEntitlement',
  'Actions::Katello::UpstreamSubscriptions::RemoveEntitlements',
  'Actions::Katello::UpstreamSubscriptions::UpdateEntitlements',
];

export const SUBSCRIPTION_TABLE_NAME = 'Katello::Subscriptions';
export const SUBSCRIPTION_TABLE_COLUMNS = [
  {
    key: 'id',
    label: __('Name'),
    value: false,
  },
  {
    key: 'product_id',
    label: __('SKU'),
    value: false,
  },
  {
    key: 'contract_number',
    label: __('Contract'),
    value: false,
  },
  {
    key: 'start_date',
    label: __('Start date'),
    value: false,
  },
  {
    key: 'end_date',
    label: __('End date'),
    value: false,
  },
  {
    key: 'virt_who',
    label: __('Requires virt-who'),
    value: false,
  },
  {
    key: 'type',
    label: __('Type'),
    value: false,
  },
  {
    key: 'quantity',
    label: __('Entitlements'),
    value: false,
  },
  {
    key: 'product_host_count',
    label: __('Hosts'),
    value: false,
  },
];

export const SUBSCRIPTION_TABLE_DEFAULT_COLUMNS = [
  'id',
  'product_id',
  'contract_number',
  'start_date',
  'end_date',
  'virt_who',
  'quantity',
  'type',
  'product_host_count',
];
