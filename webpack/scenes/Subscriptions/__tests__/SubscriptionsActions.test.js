import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import configureMockStore from 'redux-mock-store';
import { mockRequest, mockReset } from '../../../mockRequest';
import { requestSuccessResponse, successActions, failureActions } from './subscriptions.fixtures';

import { loadSubscriptions } from '../SubscriptionActions';

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
        url: '/katello/api/v2/subscriptions',
        status: 422,
      });
      return store.dispatch(loadSubscriptions())
        .then(() => expect(store.getActions()).toEqual(failureActions));
    },
  );
  it(
    'creates SUBSCRIPTIONS_REQUEST and ends with success',
    () => {
      mockRequest({
        url: '/katello/api/v2/subscriptions',
        response: requestSuccessResponse,
      });
      return store.dispatch(loadSubscriptions())
        .then(() => expect(store.getActions()).toEqual(successActions));
    },
  );
});
