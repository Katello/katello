import Immutable from 'seamless-immutable';
import {
  ORGANIZATION_PRODUCTS_REQUEST,
  ORGANIZATION_PRODUCTS_SUCCESS,
  ORGANIZATION_PRODUCTS_FAILURE,
} from '../OrganizationProductsConstants';
import reducer from '../OrganizationProductsReducer';
import organizationProductsData from './organizationProducts.fixtures.json';

describe('OrganizationProducts reducer', () => {
  const initialState = Immutable({
    loading: false,
    error: null,
    results: [],
  });

  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('should handle ORGANIZATION_PRODUCTS_REQUEST', () => {
    const action = {
      type: ORGANIZATION_PRODUCTS_REQUEST,
    };

    const newState = reducer(initialState, action);

    expect(newState.loading).toBe(true);
    expect(newState.error).toBeNull();
    expect(newState.results).toEqual([]);
  });

  it('should handle ORGANIZATION_PRODUCTS_SUCCESS', () => {
    const loadingState = initialState.set('loading', true);
    const action = {
      type: ORGANIZATION_PRODUCTS_SUCCESS,
      payload: organizationProductsData,
    };

    const newState = reducer(loadingState, action);

    expect(newState.loading).toBe(false);
    expect(newState.results).toEqual(organizationProductsData.results);
    expect(newState.total).toEqual(organizationProductsData.total);
    expect(newState.subtotal).toEqual(organizationProductsData.subtotal);
    expect(newState.page).toEqual(organizationProductsData.page);
    expect(newState.per_page).toEqual(organizationProductsData.per_page);
  });

  it('should handle ORGANIZATION_PRODUCTS_FAILURE', () => {
    const loadingState = initialState.set('loading', true);
    const error = new Error('Failed to load products');
    const action = {
      type: ORGANIZATION_PRODUCTS_FAILURE,
      payload: error,
    };

    const newState = reducer(loadingState, action);

    expect(newState.loading).toBe(false);
    expect(newState.error).toMatchObject({
      message: 'Failed to load products',
    });
    expect(newState.results).toEqual([]);
  });

  it('should maintain other state properties on success', () => {
    const stateWithData = initialState.merge({
      loading: true,
      customProp: 'customValue',
    });
    const action = {
      type: ORGANIZATION_PRODUCTS_SUCCESS,
      payload: {
        ...organizationProductsData,
        orgId: 1,
      },
    };

    const newState = reducer(stateWithData, action);

    expect(newState.loading).toBe(false);
    expect(newState.orgId).toEqual(1);
    expect(newState.results).toEqual(organizationProductsData.results);
  });
});
