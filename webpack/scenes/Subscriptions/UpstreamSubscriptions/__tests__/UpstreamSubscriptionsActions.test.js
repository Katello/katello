import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import {
  requestSuccessResponse,
  getSuccessActions,
  getFailureActions,
  saveSuccessActions,
  saveFailureActions,
} from './upstreamSubscriptions.fixtures';
import { getTaskSuccessResponse } from '../../../Tasks/__tests__/task.fixtures';

import { loadUpstreamSubscriptions, saveUpstreamSubscriptions } from '../UpstreamSubscriptionsActions';
import { mock as mockApi, mockErrorRequest } from '../../../../mockRequest';

const mockStore = configureMockStore([thunk]);
const store = mockStore({ subscriptions: Immutable({}) });

afterEach(() => {
  store.clearActions();
  mockApi.reset();
});

describe('upstream subscription actions', () => {
  const url = '/katello/api/v2/organizations/1/upstream_subscriptions';

  describe('creates UPSTREAM_SUBSCRIPTIONS_REQUEST', () => {
    it('and then fails with 422', async () => {
      mockErrorRequest({
        url,
        status: 422,
      });
      await store.dispatch(loadUpstreamSubscriptions());
      expect(store.getActions()).toEqual(getFailureActions);
    });

    it('and ends with success', async () => {
      mockApi.onGet(url).reply(200, requestSuccessResponse);

      await store.dispatch(loadUpstreamSubscriptions());
      expect(store.getActions()).toEqual(getSuccessActions);
    });
  });

  describe('creates SAVE_UPSTREAM_SUBSCRIPTIONS_REQUEST', () => {
    const subscriptionData = {
      pools: [{ id: 'abcde', quantity: 100 }],
    };

    it('and then fails with 422', async () => {
      mockErrorRequest({
        url,
        status: 422,
        method: 'POST',
      });

      await store.dispatch(saveUpstreamSubscriptions(subscriptionData));
      expect(store.getActions()).toEqual(saveFailureActions);
    });

    it('and ends with success', async () => {
      mockApi.onPost(url).reply(200, getTaskSuccessResponse);

      await store.dispatch(saveUpstreamSubscriptions(subscriptionData));
      expect(store.getActions()).toEqual(saveSuccessActions);
    });
  });
});
