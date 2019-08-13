import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import configureMockStore from 'redux-mock-store';
import { mock, mockRequest, mockErrorRequest } from '../../../mockRequest';
import {
  failureActions,
  successActions,
  requestSuccessResponse,
} from './products.fixtures';
import { loadProducts } from '../ProductActions';

const mockStore = configureMockStore([thunk]);
const store = mockStore({ e: Immutable({}) });

beforeEach(() => {
  store.clearActions();
  mock.reset();
});

describe('product actions', () => {
  describe('loadProducts', () => {
    it('handles failed PRODUCTS_REQUEST', async () => {
      mockErrorRequest({
        url: '/katello/api/v2/organizations/1/products/',
        status: 422,
      });
      await store.dispatch(loadProducts());
      expect(store.getActions()).toEqual(failureActions);
    });

    it('handles successful PRODUCTS_REQUEST', async () => {
      mockRequest({
        url: '/katello/api/v2/organizations/1/products/',
        response: requestSuccessResponse,
      });
      await store.dispatch(loadProducts());
      expect(store.getActions()).toEqual(successActions);
    });
  });
});
