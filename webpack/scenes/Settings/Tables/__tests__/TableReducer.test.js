import * as types from '../TableConstants';
import {
  requestSuccessResponse,
  tableRecord,
} from './Table.fixtures';
import reducer from '../TableReducer';

describe('Tables reducer', () => {
  it('should return the initial state', () => {
    const state = reducer(undefined, {});
    expect(state).toEqual({ loading: false });
  });

  it('should keep loading state on TABLES_REQUEST', () => {
    const state = reducer(undefined, { type: types.TABLES_REQUEST });
    expect(state.loading).toBe(true);
  });

  it('should pull table list from response TABLES_SUCCESS', () => {
    const state = reducer(undefined, {
      type: types.TABLES_SUCCESS,
      payload: requestSuccessResponse,
    });
    expect(state.loading).toBe(false);
    expect(state['Katello::Subscriptions']).toBeDefined();
    expect(state['Katello::Subscriptions'].id).toBe(36);
    expect(state['Katello::Subscriptions'].name).toBe('Katello::Subscriptions');
    expect(state['Katello::Subscriptions'].columns).toEqual([
      'id', 'product_id', 'contract_number', 'start_date', 'end_date',
    ]);
  });


  it('should create response for CREATE_TABLE_SUCCESS', () => {
    const state = reducer(undefined, {
      type: types.CREATE_TABLE_SUCCESS,
      payload: [tableRecord],
    });
    expect(state.loading).toBe(false);
    expect(state['Katello::Subscriptions'].id).toBe(36);
    expect(state['Katello::Subscriptions'].name).toBe('Katello::Subscriptions');
  });

  it('should update response UPDATE_TABLE_SUCCESS', () => {
    const state = reducer(undefined, {
      type: types.UPDATE_TABLE_SUCCESS,
      payload: [tableRecord],
    });
    expect(state.loading).toBe(false);
    expect(state['Katello::Subscriptions'].id).toBe(36);
    expect(state['Katello::Subscriptions'].name).toBe('Katello::Subscriptions');
  });

  it('should handle TABLES_FAILURE', () => {
    const state = reducer(undefined, {
      type: types.TABLES_FAILURE,
      error: 'Failed to load tables',
    });
    expect(state.loading).toBe(false);
  });
});
