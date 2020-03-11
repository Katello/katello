import Immutable from 'seamless-immutable';
import { getTaskSuccessResponse } from '../../../Tasks/__tests__/task.fixtures';
import { toastErrorAction, failureAction } from '../../../../services/api/testHelpers';

export const initialState = Immutable({
  loading: true,
  results: [],
  pagination: {
    page: 0,
    perPage: 20,
  },
  itemCount: 0,
});

export const loadingState = Immutable({
  loading: true,
  results: [],
  pagination: {
    page: 0,
    perPage: 20,
  },
  itemCount: 0,
});

export const taskSuccessResponse = getTaskSuccessResponse;

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
      id: '8a99f9815e718933015e85b19e1e11d7',
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
      id: '8a99f9815e718933015e85b1bfd211db',
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
      id: '8a99f9815e718933015e85b19e1e11d7',
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
      id: '8a99f9815e718933015e85b1bfd211db',
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
  },
  itemCount: 2,
});

export const initialSaveState = Immutable({
  loading: true,
});

export const saveSuccessState = Immutable({
  loading: false,
  task: getTaskSuccessResponse,
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
});

export const saveErrorState = Immutable({
  loading: false,
  error: 'Unable to process request.',
});

export const getSuccessActions = [
  {
    type: 'UPSTREAM_SUBSCRIPTIONS_REQUEST',
  },
  {
    response: requestSuccessResponse,
    type: 'UPSTREAM_SUBSCRIPTIONS_SUCCESS',
  },
];

export const getFailureActions = [
  {
    type: 'UPSTREAM_SUBSCRIPTIONS_REQUEST',
  },
  failureAction('UPSTREAM_SUBSCRIPTIONS_FAILURE'),
  toastErrorAction(),
];

export const saveSuccessActions = [
  {
    type: 'SAVE_UPSTREAM_SUBSCRIPTIONS_REQUEST',
  },
  {
    type: 'GET_TASK_REQUEST',
  },
  {
    response: getTaskSuccessResponse,
    type: 'SAVE_UPSTREAM_SUBSCRIPTIONS_SUCCESS',
  },
];

export const saveFailureActions = [
  {
    type: 'SAVE_UPSTREAM_SUBSCRIPTIONS_REQUEST',
  },
  failureAction('SAVE_UPSTREAM_SUBSCRIPTIONS_FAILURE'),
  toastErrorAction(),
];
