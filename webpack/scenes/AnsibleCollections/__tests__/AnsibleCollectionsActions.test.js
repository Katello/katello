import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import configureMockStore from 'redux-mock-store';
import { mockRequest, mockErrorRequest, mockReset } from '../../../mockRequest';
import { getAnsibleCollections } from '../AnsibleCollectionsActions';
import {
  ansibleCollectionsErrorActions,
  ansibleCollectionsSuccessActions,
  results,
} from './AnsibleCollections.fixtures';

const mockStore = configureMockStore([thunk]);
const store = mockStore({ ansibleCollections: Immutable({}) });
const endpoint = '/katello/api/v2/ansible_collections';

afterEach(() => {
  store.clearActions();
  mockReset();
});

describe('ansible collections actions', () => {
  describe('getAnsibleCollections', () => {
    it(
      'creates ANSIBLE_COLLECTIONS_REQUEST and then fails with 500 on bad request',
      async () => {
        mockErrorRequest({
          url: endpoint,
        });
        await store.dispatch(getAnsibleCollections());
        expect(store.getActions())
          .toEqual(ansibleCollectionsErrorActions);
      },
    );

    it(
      'creates ANSIBLE_COLLECTIONS_REQUEST and then return successfully',
      async () => {
        mockRequest({
          url: endpoint,
          response: results,
        });
        await store.dispatch(getAnsibleCollections());
        expect(store.getActions())
          .toEqual(ansibleCollectionsSuccessActions);
      },
    );
  });
});
