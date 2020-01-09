import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import configureMockStore from 'redux-mock-store';
import { disableRepository, loadEnabledRepos } from '../enabled.js';
import { mock as mockApi } from '../../../../mockRequest';
import {
  ENABLED_REPOSITORIES_REQUEST,
  DISABLE_REPOSITORY_REQUEST,
} from '../../../consts';

const mockStore = configureMockStore([thunk]);
const store = mockStore({ e: Immutable({}) });

describe('RedHatRepositories enabled actions', () => {
  describe('disableRepository', () => {
    it('dispatches DISABLE_REPOSITORY_REQUEST', async () => {
      const mockRepo = { // don't need actual values because just checking that the action matches
        productId: 'some-product-id',
        contentId: 'some-content-id',
        basearch: 'some-base-search',
        releasever: 'some-releasever',
      };
      mockApi.onPut(`/products/${mockRepo.productId}/repository_sets/${mockRepo.contentId}/disable`).reply(200, []);

      await store.dispatch(disableRepository(mockRepo));
      expect(store.getActions()).toContainEqual({
        type: DISABLE_REPOSITORY_REQUEST,
        repository: mockRepo,
      });
    });
  });
  describe('loadEnabledRepos', () => {
    it('dispatches ENABLED_REPOSITORIES_REQUEST', async () => {
      mockApi.onGet('/repositories').reply(200, []);

      await store.dispatch(loadEnabledRepos());
      expect(store.getActions()).toContainEqual({
        type: ENABLED_REPOSITORIES_REQUEST,
        silent: false,
        params: {},
      });
    });
  });
});
