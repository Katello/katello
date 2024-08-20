import Immutable from 'seamless-immutable';
import { toastErrorAction, failureAction } from '../../../services/api/testHelpers';

export const initialState = Immutable({
  loading: true,
  results: [],
  pagination: {
    page: 0,
    perPage: 20,
  },
  itemCount: 0,
  quantitiesLoading: false,
  availableQuantities: null,
  task: undefined,
  tableColumns: [],
  selectedTableColumns: [],
});

export const loadingState = Immutable({
  ...initialState,
});

export const emptyState = Immutable({
  ...loadingState,
  loading: false,
});

export const requestSuccessResponse = Immutable({
  organization: {},
  total: 81,
  subtotal: 81,
  page: 1,
  per_page: 2,
  error: null,
  search: null,
  sort: {
    by: 'cp_id',
    order: 'asc',
  },
  results: [
    {
      id: 3,
      cp_id: 'ff8080815ea5ea44015ea617b1a5000b',
      subscription_id: 2,
      name: 'zoo',
      start_date: '2017-09-21 16:18:44 -0400',
      end_date: '2047-09-14 15:18:44 -0500',
      available: -2,
      quantity: -1,
      consumed: 1,
      account_number: null,
      contract_number: null,
      support_level: null,
      product_id: '853987721546',
      sockets: null,
      cores: null,
      ram: null,
      instance_multiplier: 1,
      stacking_id: null,
      multi_entitlement: null,
      type: 'NORMAL',
      product_name: 'zoo',
      unmapped_guest: false,
      virt_only: false,
      virt_who: false,
      product_host_count: 1,
    },
    {
      id: 4,
      cp_id: 'ff8080815ea5ea44015ebb08e95a0024',
      subscription_id: 3,
      name: 'hsdfhsdh',
      start_date: '2017-09-25 17:54:36 -0400',
      end_date: '2047-09-18 16:54:36 -0500',
      available: -1,
      quantity: -1,
      consumed: 0,
      account_number: null,
      contract_number: null,
      support_level: null,
      product_id: '947637693017',
      sockets: null,
      cores: null,
      ram: null,
      instance_multiplier: 1,
      stacking_id: null,
      multi_entitlement: null,
      type: 'NORMAL',
      product_name: 'hsdfhsdh',
      unmapped_guest: false,
      virt_only: false,
      virt_who: false,
      product_host_count: 0,
    },
  ],
});

export const quantitiesRequestSuccessResponse = Immutable({
  results: [
    {
      id: '9a95f981519abf020151ab082c5e0313',
      quantity: 10000,
      available: 100,
      start_date: '2016-12-15T05:00:00+0000',
      end_date: '2032-01-01T04:59:59+0000',
      contract_number: '10880011',
      consumed: 9469,
      product_name: 'Some RH Product',
      product_id: 'Z3BRU11',
      subscription_id: '3802241',
      local_pool_ids: [
        4,
        5,
      ],
      product_host_count: 9469,
    },
    {
      id: '6b123381519abf020151ab082c5e4678',
      quantity: 400,
      available: 40,
      start_date: '2016-12-15T05:00:00+0000',
      end_date: '2032-01-01T04:59:59+0000',
      contract_number: '10880011',
      consumed: 9469,
      product_name: 'Another RH Product',
      product_id: 'ABIC300',
      subscription_id: '3808964',
      local_pool_ids: [
        6,
      ],
      product_host_count: 9469,
    },
  ],
  page: 1,
  per_page: 10,
  search: null,
  sort: {
    by: 'cp_id',
    order: 'asc',
  },
  subtotal: 3,
  total: 3,
});

export const groupedSubscriptions = Immutable({
  loading: false,
  manifestModalOpened: false,
  results: [
    {
      id: 3,
      cp_id: 'ff8080815ea5ea44015ea617b1a5000b',
      subscription_id: 3,
      name: 'zoo',
      start_date: '2017-09-21 16:18:44 -0400',
      end_date: '2047-09-14 15:18:44 -0500',
      available: -2,
      quantity: -1,
      consumed: 1,
      account_number: null,
      contract_number: null,
      support_level: null,
      product_id: '853987721546',
      sockets: null,
      cores: null,
      ram: null,
      instance_multiplier: 1,
      stacking_id: null,
      multi_entitlement: null,
      type: 'NORMAL',
      product_name: 'zoo',
      unmapped_guest: false,
      virt_only: false,
      virt_who: false,
      product_host_count: 1,
    },
    {
      id: 4,
      cp_id: 'ff8080815ea5ea44015ebb08e95a0024',
      subscription_id: 3,
      name: 'hsdfhsdh',
      start_date: '2017-09-25 17:54:36 -0400',
      end_date: '2047-09-18 16:54:36 -0500',
      available: -1,
      quantity: -1,
      consumed: 0,
      account_number: null,
      contract_number: null,
      support_level: null,
      product_id: '853987721546',
      sockets: null,
      cores: null,
      ram: null,
      instance_multiplier: 1,
      stacking_id: null,
      multi_entitlement: null,
      type: 'NORMAL',
      product_name: 'hsdfhsdh',
      unmapped_guest: false,
      virt_only: false,
      virt_who: false,
      product_host_count: 0,
    },
  ],
  searchIsActive: false,
  search: undefined,
  pagination: {
    page: 1,
    perPage: 2,
  },
  itemCount: 81,
  quantitiesLoading: false,
  availableQuantities: null,
  tableColumns: [],
  selectedTableColumns: [],
});

export const successState = Immutable({
  loading: false,
  results: [
    {
      id: 3,
      cp_id: 'ff8080815ea5ea44015ea617b1a5000b',
      subscription_id: 2,
      name: 'zoo',
      start_date: '2017-09-21 16:18:44 -0400',
      end_date: '2047-09-14 15:18:44 -0500',
      available: -2,
      quantity: -1,
      consumed: 1,
      account_number: null,
      contract_number: null,
      support_level: null,
      product_id: '853987721546',
      sockets: null,
      cores: null,
      ram: null,
      instance_multiplier: 1,
      stacking_id: null,
      multi_entitlement: null,
      type: 'NORMAL',
      product_name: 'zoo',
      unmapped_guest: false,
      virt_only: false,
      virt_who: false,
      product_host_count: 1,
    },
    {
      id: 4,
      cp_id: 'ff8080815ea5ea44015ebb08e95a0024',
      subscription_id: 3,
      name: 'hsdfhsdh',
      start_date: '2017-09-25 17:54:36 -0400',
      end_date: '2047-09-18 16:54:36 -0500',
      available: -1,
      quantity: -1,
      consumed: 0,
      account_number: null,
      contract_number: null,
      support_level: null,
      product_id: '947637693017',
      sockets: null,
      cores: null,
      ram: null,
      instance_multiplier: 1,
      stacking_id: null,
      multi_entitlement: null,
      type: 'NORMAL',
      product_name: 'hsdfhsdh',
      unmapped_guest: false,
      virt_only: false,
      virt_who: false,
      product_host_count: 0,
    },
  ],
  searchIsActive: false,
  search: undefined,
  pagination: {
    page: 1,
    perPage: 2,
  },
  itemCount: 81,
  quantitiesLoading: false,
  availableQuantities: null,
  tableColumns: [],
  selectedTableColumns: [],
});
export const permissionDeniedState = Immutable({
  loading: false,
  results: [],
  searchIsActive: false,
  search: undefined,
  pagination: {
    page: 1,
    perPage: 2,
  },
  missingPermissions: ['view_subscriptions'],
  itemCount: 0,
  quantitiesLoading: false,
  availableQuantities: null,
  tableColumns: [],
  selectedTableColumns: [],
});
export const settingsSuccessState = Immutable({
  tables: {
    loading: false,
    id: 22,
    name: 'Katello::Subscriptions',
    columns: [
      'id',
      'product_id',
      'contract_number',
      'start_date',
      'end_date',
    ],
    created_at: '2018-06-12 17:05:03 -0600',
    updated_at: '2018-06-20 13:55:42 -0600',
  },
});

export const errorState = Immutable({
  loading: false,
  pagination: {
    page: 0,
    perPage: 20,
  },
  itemCount: 0,
  results: [],
  quantitiesLoading: false,
  availableQuantities: null,
  tableColumns: [],
  selectedTableColumns: [],
});

export const quantitiesSuccessState = Immutable({
  ...successState,
  quantitiesLoading: false,
  availableQuantities: {
    4: 100,
    5: 100,
    6: 40,
  },
});

export const loadingQuantitiesState = Immutable({
  ...successState,
  quantitiesLoading: true,
});

export const quantitiesErrorState = Immutable({
  ...successState,
  quantitiesLoading: false,
  availableQuantities: {},
});

export const successActions = [
  {
    type: 'SUBSCRIPTIONS_REQUEST',
  },
  {
    type: 'SUBSCRIPTIONS_SUCCESS',
    response: requestSuccessResponse,
    search: undefined,
  },
];

export const failureActions = [
  {
    type: 'SUBSCRIPTIONS_REQUEST',
  },
  failureAction('SUBSCRIPTIONS_FAILURE'),
  toastErrorAction(),
];

export const poolsUpdate = [{
  id: 1,
  quantity: 32,
}, {
  id: 42,
  quantity: 83,
}];

export const updateQuantitySuccessActions = [
  {
    type: 'UPDATE_QUANTITY_REQUEST',
  },
  {
    type: 'UPDATE_QUANTITY_SUCCESS',
    response: requestSuccessResponse,
  },
];

export const updateQuantityFailureActions = [
  {
    type: 'UPDATE_QUANTITY_REQUEST',
  },
  failureAction('UPDATE_QUANTITY_FAILURE'),
  toastErrorAction(),
];

export const loadQuantitiesFailureActions = [
  {
    type: 'SUBSCRIPTIONS_QUANTITIES_REQUEST',
  },
  failureAction('SUBSCRIPTIONS_QUANTITIES_FAILURE', 'Request failed with status code 500'),
  toastErrorAction('Request failed with status code 500'),
];

export const loadQuantitiesSuccessActionPayload = { 4: 100, 5: 100, 6: 40 };

export const loadQuantitiesSuccessActions = [
  {
    type: 'SUBSCRIPTIONS_QUANTITIES_REQUEST',
  },
  {
    type: 'SUBSCRIPTIONS_QUANTITIES_SUCCESS',
    payload: loadQuantitiesSuccessActionPayload,
  },
];
export const tableColumns = [
  {
    key: 'id',
    label: 'Name',
    value: true,
  },
  {
    key: 'product_id',
    label: 'SKU',
    value: true,
  },
  {
    key: 'contract_number',
    label: 'Contract',
    value: true,
  },
  {
    key: 'start_date',
    label: 'Start Date',
    value: true,
  },
  {
    key: 'end_date',
    label: 'End Date',
    value: true,
  },
  {
    key: 'virt_who',
    label: 'Requires Virt-Who',
    value: true,
  },
  {
    key: 'type',
    label: 'Type',
    value: true,
  },
  {
    key: 'consumed',
    label: 'Consumed',
    value: true,
  },
  {
    key: 'quantity',
    label: 'Entitlements',
    value: true,
  },
  {
    key: 'product_host_count',
    label: 'Product Host Count',
    value: true,
  },
];

export const loadTableColumnsSuccessAction = [
  {
    type: 'UPDATE_SUBSCRIPTION_COLUMNS',
    payload: {
      enabledColumns: [
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
      ],
    },
  },
  {
    payload: {
      tableColumns,
    },
    type: 'SUBSCRIPTIONS_COLUMNS_REQUEST',
  },
];
export const loadingColumnsState = Immutable({
  ...successState,
});
