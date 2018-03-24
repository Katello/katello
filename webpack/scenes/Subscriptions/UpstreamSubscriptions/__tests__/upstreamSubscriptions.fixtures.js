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
  total: 2,
  subtotal: 2,
  page: 1,
  per_page: null,
  error: null,
  search: null,
  sort: {
    by: null,
    order: null,
  },
  results: [
    {
      pool_id: '8a99f9815e718933015e85b19e1e11d7',
      quantity: 200,
      start_date: '2017-09-15T04:00:00+0000',
      end_date: '2018-09-15T03:59:59+0000',
      contract_number: '11480900',
      consumed: 100,
      product_name: 'Red Hat Enterprise Linux for Power, LE, Premium (IFL, up to 4 LPARs)',
      product_id: 'RH00284',
      subscription_id: '4753270',
    },
    {
      pool_id: '8a99f9815e718933015e85b1bfd211db',
      quantity: 250,
      start_date: '2017-09-15T04:00:00+0000',
      end_date: '2018-09-15T03:59:59+0000',
      contract_number: '11480898',
      consumed: 125,
      product_name: 'Red Hat Enterprise Linux Server for ATOM with Smart Management, Hyperscale, Standard (5 Physical Nodes)',
      product_id: 'RH00447',
      subscription_id: '4753271',
    },
  ],
  organization_id: 1,
});

export const successState = Immutable({
  loading: false,
  results: [
    {
      pool_id: '8a99f9815e718933015e85b19e1e11d7',
      quantity: 200,
      start_date: '2017-09-15T04:00:00+0000',
      end_date: '2018-09-15T03:59:59+0000',
      contract_number: '11480900',
      consumed: 100,
      product_name: 'Red Hat Enterprise Linux for Power, LE, Premium (IFL, up to 4 LPARs)',
      product_id: 'RH00284',
      subscription_id: '4753270',
    },
    {
      pool_id: '8a99f9815e718933015e85b1bfd211db',
      quantity: 250,
      start_date: '2017-09-15T04:00:00+0000',
      end_date: '2018-09-15T03:59:59+0000',
      contract_number: '11480898',
      consumed: 125,
      product_name: 'Red Hat Enterprise Linux Server for ATOM with Smart Management, Hyperscale, Standard (5 Physical Nodes)',
      product_id: 'RH00447',
      subscription_id: '4753271',
    },
  ],
  searchIsActive: false,
  search: undefined,
  pagination: {
    page: 1,
    perPage: 20,
    total: 2,
    subtotal: 2,
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
    type: 'UPSTREAM_SUBSCRIPTIONS_REQUEST',
  },
  {
    response: requestSuccessResponse,
    type: 'UPSTREAM_SUBSCRIPTIONS_SUCCESS',
  },
];

export const failureActions = [
  {
    type: 'UPSTREAM_SUBSCRIPTIONS_REQUEST',
  },
  {
    result: new Error('Request failed with status code 422'),
    type: 'UPSTREAM_SUBSCRIPTIONS_FAILURE',
  },
];
