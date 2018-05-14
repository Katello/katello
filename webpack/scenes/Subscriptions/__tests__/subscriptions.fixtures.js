import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  loading: true,
  results: [],
  pagination: {
    page: 0,
    perPage: 20,
  },
  itemCount: 0,
  quantitiesLoading: false,
  availableQuantities: {},
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
    },
  ],
});

export const requestSuccessResponseWithRHSubscriptions = Immutable({
  organization: {},
  total: 81,
  subtotal: 1,
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
      id: 4,
      cp_id: '4028f95a62ce96190162cf435202005b',
      subscription_id: 5,
      name: 'Some RH Product',
      start_date: '2013-02-28 18:00:00 -1100',
      end_date: '2021-12-31 17:59:59 -1100',
      available: 12,
      quantity: 12,
      consumed: 0,
      account_number: 1000000,
      contract_number: 20000000,
      support_level: 'Self-Support',
      product_id: 'Z3BRU11',
      sockets: null,
      cores: null,
      ram: null,
      instance_multiplier: 1,
      stacking_id: null,
      multi_entitlement: null,
      type: 'NORMAL',
      product_name: 'Some RH Product',
      unmapped_guest: false,
      virt_only: false,
      virt_who: false,
      upstream: true,
    },
  ],
});

export const quantitiesRequestSuccessResponse = Immutable({
  results: [
    {
      pool_id: '9a95f981519abf020151ab082c5e0313',
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
    },
    {
      pool_id: '6b123381519abf020151ab082c5e4678',
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
  availableQuantities: {},
});

export const errorState = Immutable({
  loading: false,
  error: 'Unable to process request.',
  pagination: {
    page: 0,
    perPage: 20,
  },
  itemCount: 0,
  results: [],
  quantitiesLoading: false,
  availableQuantities: {},
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
  quantitiesError: 'Unable to process request.',
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

export const successActionsWithQuantityLoad = [
  {
    type: 'SUBSCRIPTIONS_REQUEST',
  },
  {
    type: 'SUBSCRIPTIONS_SUCCESS',
    response: requestSuccessResponseWithRHSubscriptions,
    search: undefined,
  },
  {
    type: 'SUBSCRIPTIONS_QUANTITIES_REQUEST',
  },
];

export const failureActions = [
  {
    type: 'SUBSCRIPTIONS_REQUEST',
  },
  {
    error: 'Request failed with status code 422',
    type: 'SUBSCRIPTIONS_FAILURE',
  },
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
    quantities: poolsUpdate,
  },
  {
    response: requestSuccessResponse,
    type: 'UPDATE_QUANTITY_SUCCESS',
  },
];

export const updateQuantityFailureActions = [
  {
    type: 'UPDATE_QUANTITY_REQUEST',
    quantities: poolsUpdate,
  },
  {
    error: 'Request failed with status code 422',
    type: 'UPDATE_QUANTITY_FAILURE',
  },
];

export const loadQuantitiesFailureActions = [
  {
    type: 'SUBSCRIPTIONS_QUANTITIES_REQUEST',
  },
  {
    error: 'Request failed with status code 500',
    type: 'SUBSCRIPTIONS_QUANTITIES_FAILURE',
  },
];

export const loadQuantitiesSuccessActions = [
  {
    type: 'SUBSCRIPTIONS_QUANTITIES_REQUEST',
  },
  {
    type: 'SUBSCRIPTIONS_QUANTITIES_SUCCESS',
    response: quantitiesRequestSuccessResponse,
  },
];
