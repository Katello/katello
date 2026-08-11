import Immutable from 'seamless-immutable';
import { getTaskSuccessResponse } from '../../../Tasks/__tests__/task.fixtures';

export const requestSuccessResponse = Immutable({
  total: 2,
  subtotal: 2,
  page: 1,
  per_page: 20,
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
      available: 100,
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
      available: 125,
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

export const emptyListResponse = {
  total: 0,
  subtotal: 0,
  page: 1,
  per_page: 20,
  error: null,
  search: null,
  sort: {
    by: null,
    order: null,
  },
  results: [],
  organization_id: 1,
};

export const taskSuccessResponse = getTaskSuccessResponse;
