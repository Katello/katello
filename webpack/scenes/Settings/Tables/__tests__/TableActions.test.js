import axios from '@theforeman/vendor/axios';
import MockAdapter from 'axios-mock-adapter';
import thunk from '@theforeman/vendor/redux-thunk';
import Immutable from '@theforeman/vendor/seamless-immutable';
import configureMockStore from 'redux-mock-store';
import { mockRequest, mockReset } from '../../../../mockRequest';
import { loadTables, createColumns, updateColumns } from '../TableActions';
import {
  requestSuccessResponse,
  getSuccessActions,
  getFailureActions,
  createSuccessActions,
  createFailureActions,
  updateSuccessActions,
  updateFailureActions,
  tableRecord,
} from './Table.fixtures';

const accessDenied = {
  error: {
    message: 'Access denied',
    details: 'You are trying access the preferences of a different user',
  },
};
const mockStore = configureMockStore([thunk]);
const store = mockStore({ settings: Immutable({}) });
const testTableName = 'Katello::Subscriptions';

beforeEach(() => {
  store.clearActions();
  mockReset();
});

describe('table actions', () => {
  it('creates TABLES_REQUEST with success', () => {
    mockRequest({
      url: '/api/v2/users/1/table_preferences',
      status: 200,
      response: requestSuccessResponse,
    });
    return store.dispatch(loadTables())
      .then(() => expect(store.getActions()).toEqual(getSuccessActions));
  });
  it('creates TABLES_REQUEST with failure', () => {
    mockRequest({
      url: '/api/v2/users/1/table_preferences',
      status: 403,
      response: accessDenied,
    });
    return store.dispatch(loadTables())
      .then(() => expect(store.getActions()).toEqual(getFailureActions));
  });

  it('creates SAVE_CREATE_TABLE and ends with success', () => {
    const mock = new MockAdapter(axios);
    mock.onPost('/api/v2/users/1/table_preferences').reply(200, tableRecord);

    return store.dispatch(createColumns())
      .then(() => expect(store.getActions()).toEqual(createSuccessActions));
  });

  it('creates CREATE_TABLE with failure', () => {
    const mock = new MockAdapter(axios);
    mock.onPost('/api/v2/users/1/table_preferences').reply(403, accessDenied);

    return store.dispatch(createColumns({ name: 'Test', columns: [] }))
      .then(() => expect(store.getActions()).toEqual(createFailureActions));
  });

  it('creates UPDATE_TABLE and ends with success', () => {
    const mock = new MockAdapter(axios);
    mock.onPut(`/api/v2/users/1/table_preferences/${testTableName}`).reply(200, tableRecord);

    return store.dispatch(updateColumns(tableRecord))
      .then(() => expect(store.getActions()).toEqual(updateSuccessActions));
  });
  it('creates UPDATE_TABLE with failure', () => {
    const mock = new MockAdapter(axios);
    mock.onPut(`/api/v2/users/1/table_preferences/${testTableName}`).reply(403, accessDenied);

    return store.dispatch(updateColumns(tableRecord))
      .then(() => expect(store.getActions()).toEqual(updateFailureActions));
  });
});
