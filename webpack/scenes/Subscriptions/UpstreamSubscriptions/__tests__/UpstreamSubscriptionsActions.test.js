import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import { mockRequest, mockReset } from '../../../../mockRequest';
import { requestSuccessResponse, successActions, failureActions } from './upstreamSubscriptions.fixtures';

import { loadUpstreamSubscriptions } from '../UpstreamSubscriptionsActions';

const mockStore = configureMockStore([thunk]);
const store = mockStore({ subscriptions: Immutable({}) });

afterEach(() => {
  store.clearActions();
  mockReset();
});

describe('subscription actions', () => {
  it(
    'creates STATISTICS_DATA_REQUEST and then fails with 422',
    () => {
      mockRequest({
        url: '/katello/api/v2/organizations/1/upstream_subscriptions',
        status: 422,
      });
      return store.dispatch(loadUpstreamSubscriptions({ organization_id: 1 }))
        .then(() => expect(store.getActions()).toEqual(failureActions));
    },
  );
  it(
    'creates SUBSCRIPTIONS_REQUEST and ends with success',
    () => {
      mockRequest({
        url: '/katello/api/v2/organizations/1/upstream_subscriptions',
        response: requestSuccessResponse,
      });
      return store.dispatch(loadUpstreamSubscriptions({ organization_id: 1 }))
        .then(() => expect(store.getActions()).toEqual(successActions));
    },
  );
});
