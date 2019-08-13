import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import configureMockStore from 'redux-mock-store';
import { disableRepository, loadEnabledRepos } from '../enabled.js';
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
        productId: null,
        contentId: null,
        basearch: null,
        releasever: null,
      };
      await store.dispatch(disableRepository(mockRepo));
      expect(store.getActions()).toContainEqual({
        type: DISABLE_REPOSITORY_REQUEST,
        repository: mockRepo,
      });
    });
  });
  describe('loadEnabledRepos', () => {
    it('dispatches ENABLED_REPOSITORIES_REQUEST', async () => {
      await store.dispatch(loadEnabledRepos());
      expect(store.getActions()).toContainEqual({
        type: ENABLED_REPOSITORIES_REQUEST,
        silent: false,
        params: {},
      });
    });
  });
});
