import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
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

const mockStore = configureMockStore([thunk]);
const store = mockStore({ subscriptions: Immutable({}) });
const mockApi = new MockAdapter(axios);

afterEach(() => {
  store.clearActions();
  mockApi.reset();
});

describe('upstream subscription actions', () => {
  const url = '/katello/api/v2/organizations/1/upstream_subscriptions';

  describe('creates UPSTREAM_SUBSCRIPTIONS_REQUEST', () => {
    it('and then fails with 422', () => {
      mockApi.onGet(url).reply(422);

      return store.dispatch(loadUpstreamSubscriptions())
        .then(() => expect(store.getActions()).toEqual(getFailureActions));
    });

    it('and ends with success', () => {
      mockApi.onGet(url).reply(200, requestSuccessResponse);

      return store.dispatch(loadUpstreamSubscriptions())
        .then(() => expect(store.getActions()).toEqual(getSuccessActions));
    });
  });

  describe('creates SAVE_UPSTREAM_SUBSCRIPTIONS_REQUEST', () => {
    const subscriptionData = {
      pools: [{ id: 'abcde', quantity: 100 }],
    };

    it('and then fails with 422', () => {
      mockApi.onPost(url).reply(422);

      return store.dispatch(saveUpstreamSubscriptions(subscriptionData))
        .then(() => expect(store.getActions()).toEqual(saveFailureActions));
    });

    it('and ends with success', () => {
      mockApi.onPost(url).reply(200, getTaskSuccessResponse);

      return store.dispatch(saveUpstreamSubscriptions(subscriptionData))
        .then(() => expect(store.getActions()).toEqual(saveSuccessActions));
    });
  });
});
