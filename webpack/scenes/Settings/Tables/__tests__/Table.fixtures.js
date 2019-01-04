import Immutable from '@theforeman/vendor/seamless-immutable';
import {
  TABLES_REQUEST,
  TABLES_SUCCESS,
  TABLES_FAILURE,
  CREATE_TABLE,
  CREATE_TABLE_SUCCESS,
  CREATE_TABLE_FAILURE,
  UPDATE_TABLE,
  UPDATE_TABLE_SUCCESS,
  UPDATE_TABLE_FAILURE,
} from '../TableConstants';

export const initialState = Immutable({
  loading: false,
});

export const loadingState = Immutable({
  loading: true,
});


export const tableRecord = Immutable({
  id: 36,
  name: 'Katello::Subscriptions',
  columns:
    [
      'id',
      'product_id',
      'contract_number',
      'start_date',
      'end_date',
    ],
  created_at: '2018-06-22 16:01:06 -0600',
  updated_at: '2018-06-22 22:38:15 -0600',
});

export const requestSuccessResponse = Immutable({
  total: 2,
  subtotal: 2,
  page: 1,
  per_page: 20,
  search: null,
  sort: {
    by: null,
    order: null,
  },
  results: [
    tableRecord,
  ],
});

export const successState = Immutable({ 'Katello::Subscriptions': tableRecord, loading: false });
export const errorState = Immutable({
  loading: false,
});

export const getSuccessActions = [
  { params: {}, type: TABLES_REQUEST },
  { payload: requestSuccessResponse, type: TABLES_SUCCESS },
];

export const getFailureActions = [
  {
    params: {},
    type: TABLES_REQUEST,
  },
  {
    error: {
      message: 'Access denied',
      details: 'You are trying access the preferences of a different user',
    },
    type: TABLES_FAILURE,
  },
];

export const createSuccessActions = [
  {
    type: CREATE_TABLE,
    params: {},
  },
  {
    payload: [tableRecord],
    type: CREATE_TABLE_SUCCESS,
  },
];

export const createFailureActions = [
  {
    type: CREATE_TABLE,
    params: { name: 'Test', columns: [] },
  },
  {
    error: {
      message: 'Access denied',
      details: 'You are trying access the preferences of a different user',
    },
    type: CREATE_TABLE_FAILURE,
  },
];

export const updateSuccessActions = [
  {
    type: UPDATE_TABLE,
    params: tableRecord,
  },
  {
    payload: [tableRecord],
    type: UPDATE_TABLE_SUCCESS,
  },
];

export const updateFailureActions = [
  {
    type: UPDATE_TABLE,
    params: tableRecord,
  },
  {
    error: {
      message: 'Access denied',
      details: 'You are trying access the preferences of a different user',
    },
    type: UPDATE_TABLE_FAILURE,
  },
];
