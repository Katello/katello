import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  loading: true,
  results: [],
  pagination: {
    page: 0,
    perPage: 20,
    total: 0,
  },
});

export const loadingState = Immutable({
  loading: true,
  results: [],
  pagination: {
    page: 0,
    perPage: 20,
    total: 0,
  },
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
    total: 81,
    subtotal: 81,
  },
});

export const errorState = Immutable({
  loading: false,
  error: 'Unable to process request.',
  pagination: {
    page: 0,
    perPage: 20,
    total: 0,
  },
  results: [],
});


export const successActions = [
  {
    type: 'SUBSCRIPTIONS_REQUEST',
  },
  {
    response: requestSuccessResponse,
    type: 'SUBSCRIPTIONS_SUCCESS',
  },
];

export const failureActions = [
  {
    type: 'SUBSCRIPTIONS_REQUEST',
  },
  {
    result: new Error('Request failed with status code 422'),
    type: 'SUBSCRIPTIONS_FAILURE',
  },
];
