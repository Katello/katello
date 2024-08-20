import { translate as __ } from 'foremanReact/common/I18n';

export const SUBSCRIPTIONS = 'SUBSCRIPTIONS';

export const SUBSCRIPTIONS_RESET_TASKS = 'SUBSCRIPTIONS_RESET_TASKS';

export const SUBSCRIPTIONS_TASK_SEARCH_SUCCESS = 'SUBSCRIPTIONS_TASK_SEARCH_SUCCESS';
export const SUBSCRIPTIONS_TASK_SEARCH_FAILURE = 'SUBSCRIPTIONS_TASK_SEARCH_FAILURE';

export const SUBSCRIPTIONS_POLL_TASK_SUCCESS = 'SUBSCRIPTIONS_POLL_TASK_SUCCESS';
export const SUBSCRIPTIONS_POLL_TASK_FAILURE = 'SUBSCRIPTIONS_POLL_TASK_FAILURE';

export const SUBSCRIPTIONS_REQUEST = 'SUBSCRIPTIONS_REQUEST';
export const SUBSCRIPTIONS_SUCCESS = 'SUBSCRIPTIONS_SUCCESS';
export const SUBSCRIPTIONS_FAILURE = 'SUBSCRIPTIONS_FAILURE';

export const UPDATE_QUANTITY_REQUEST = 'UPDATE_QUANTITY_REQUEST';
export const UPDATE_QUANTITY_SUCCESS = 'UPDATE_QUANTITY_SUCCESS';
export const UPDATE_QUANTITY_FAILURE = 'UPDATE_QUANTITY_FAILURE';

export const SUBSCRIPTIONS_QUANTITIES_REQUEST = 'SUBSCRIPTIONS_QUANTITIES_REQUEST';
export const SUBSCRIPTIONS_QUANTITIES_SUCCESS = 'SUBSCRIPTIONS_QUANTITIES_SUCCESS';
export const SUBSCRIPTIONS_QUANTITIES_FAILURE = 'SUBSCRIPTIONS_QUANTITIES_FAILURE';

export const DELETE_SUBSCRIPTIONS_REQUEST = 'DELETE_SUBSCRIPTIONS_REQUEST';
export const DELETE_SUBSCRIPTIONS_SUCCESS = 'DELETE_SUBSCRIPTIONS_SUCCESS';
export const DELETE_SUBSCRIPTIONS_FAILURE = 'DELETE_SUBSCRIPTIONS_FAILURE';

export const SUBSCRIPTIONS_COLUMNS_REQUEST = 'SUBSCRIPTIONS_COLUMNS_REQUEST';
export const UPDATE_SUBSCRIPTION_COLUMNS = 'UPDATE_SUBSCRIPTION_COLUMNS';

export const SUBSCRIPTIONS_UPDATE_SEARCH_QUERY = 'SUBSCRIPTIONS_UPDATE_SEARCH_QUERY';

export const SUBSCRIPTIONS_OPEN_DELETE_MODAL = 'SUBSCRIPTIONS_OPEN_DELETE_MODAL';
export const SUBSCRIPTIONS_CLOSE_DELETE_MODAL = 'SUBSCRIPTIONS_CLOSE_DELETE_MODAL';

export const SUBSCRIPTIONS_DISABLE_DELETE_BUTTON = 'SUBSCRIPTIONS_DISABLE_DELETE_BUTTON';
export const SUBSCRIPTIONS_ENABLE_DELETE_BUTTON = 'SUBSCRIPTIONS_ENABLE_DELETE_BUTTON';

export const SUBSCRIPTIONS_SERVICE_DOC_URL = 'https://access.redhat.com/documentation/en-us/subscription_central/2021/html-single/getting_started_with_the_subscriptions_service/index';
export const SUBSCRIPTIONS_SERVICE_URL = 'https://console.redhat.com/subscriptions';
export const SCA_URL = 'https://access.redhat.com/articles/simple-content-access';

export const MANIFEST_DELETE_TASK_LABEL = 'Actions::Katello::Organization::ManifestDelete';

export const BLOCKING_FOREMAN_TASK_TYPES = [
  'Actions::Katello::Organization::ManifestImport',
  'Actions::Katello::Organization::ManifestRefresh',
  MANIFEST_DELETE_TASK_LABEL,
  'Actions::Katello::UpstreamSubscriptions::BindEntitlements',
  'Actions::Katello::UpstreamSubscriptions::UpdateEntitlement',
  'Actions::Katello::UpstreamSubscriptions::RemoveEntitlements',
  'Actions::Katello::UpstreamSubscriptions::UpdateEntitlements',
  'Actions::Katello::Organization::SimpleContentAccess::Enable',
  'Actions::Katello::Organization::SimpleContentAccess::Disable',
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
    label: __('Start Date'),
    value: false,
  },
  {
    key: 'end_date',
    label: __('End Date'),
    value: false,
  },
  {
    key: 'virt_who',
    label: __('Requires Virt-Who'),
    value: false,
  },
  {
    key: 'type',
    label: __('Type'),
    value: false,
  },
  {
    key: 'consumed',
    label: __('Consumed'),
    value: false,
  },
  {
    key: 'quantity',
    label: __('Entitlements'),
    value: false,
  },
  {
    key: 'product_host_count',
    label: __('Product Host Count'),
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
  'consumed',
  'quantity',
  'type',
  'product_host_count',
];
