import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import configureMockStore from 'redux-mock-store';
import { mockRequest, mockErrorRequest, mockReset } from '../../../mockRequest';
import { loadOrganizationProducts } from '../OrganizationProductsActions';
import {
  ORGANIZATION_PRODUCTS_REQUEST,
  ORGANIZATION_PRODUCTS_SUCCESS,
  ORGANIZATION_PRODUCTS_FAILURE,
} from '../OrganizationProductsConstants';
import organizationProductsData from './organizationProducts.fixtures.json';

const mockStore = configureMockStore([thunk]);
const orgId = 1;
const endpoint = /\/organizations\/\d+\/products\//;

let store;

beforeEach(() => {
  store = mockStore({ organizationProducts: Immutable({}) });
});

afterEach(() => {
  mockReset();
});

describe('OrganizationProducts actions', () => {
  describe('loadOrganizationProducts', () => {
    it('creates ORGANIZATION_PRODUCTS_REQUEST and succeeds with products data', async () => {
      const params = { search: 'some-search' };

      mockRequest({
        url: endpoint,
        response: organizationProductsData,
      });

      await store.dispatch(loadOrganizationProducts(params, orgId));

      const actions = store.getActions();
      expect(actions[0]).toEqual({ type: ORGANIZATION_PRODUCTS_REQUEST });
      expect(actions[1]).toEqual({
        type: ORGANIZATION_PRODUCTS_SUCCESS,
        payload: {
          orgId,
          ...organizationProductsData,
        },
      });
    });

    it('creates ORGANIZATION_PRODUCTS_REQUEST and fails with error', async () => {
      const params = { search: 'some-search' };

      mockErrorRequest({
        url: endpoint,
      });

      await store.dispatch(loadOrganizationProducts(params, orgId));

      const actions = store.getActions();
      expect(actions[0]).toEqual({ type: ORGANIZATION_PRODUCTS_REQUEST });
      expect(actions[1].type).toEqual(ORGANIZATION_PRODUCTS_FAILURE);
      expect(actions[1].payload).toBeDefined();
    });

    it('loads products without search params', async () => {
      mockRequest({
        url: endpoint,
        response: organizationProductsData,
      });

      await store.dispatch(loadOrganizationProducts({}, orgId));

      const actions = store.getActions();
      expect(actions[0]).toEqual({ type: ORGANIZATION_PRODUCTS_REQUEST });
      expect(actions[1]).toEqual({
        type: ORGANIZATION_PRODUCTS_SUCCESS,
        payload: {
          orgId,
          ...organizationProductsData,
        },
      });
    });
  });
});
